Date: Fri, 30 Jan 2004 15:31:49 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.2-rc2-mm2
Message-Id: <20040130153149.00bcb210.akpm@osdl.org>
In-Reply-To: <20040130232103.GF9155@sun.com>
References: <1075489136.5995.30.camel@moria.arnor.net>
	<200401302007.26333.thomas.schlichter@web.de>
	<1075490624.4272.7.camel@laptop.fenrus.com>
	<20040130114701.18aec4e8.akpm@osdl.org>
	<20040130201731.GY9155@sun.com>
	<20040130123301.70009427.akpm@osdl.org>
	<20040130211256.GZ9155@sun.com>
	<20040130140024.4b409335.akpm@osdl.org>
	<20040130223105.GC9155@sun.com>
	<20040130150819.2425386b.akpm@osdl.org>
	<20040130232103.GF9155@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: thockin@sun.com
Cc: arjanv@redhat.com, thomas.schlichter@web.de, thoffman@arnor.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Tim Hockin <thockin@sun.com> wrote:
>
> > +	struct group_info *group_info = NULL;
> 
> Why init to NULL?

leftovers.

> > +	ngroups = 0;
> > +	if (!(exp->ex_flags & NFSEXP_ALLSQUASH)) {
> > +		for (i = 0; i < SVC_CRED_NGROUPS; i++) {
> > +			if (cred->cr_groups[i])
> > +				ngroups++;
> > +		}
> > +	}
> 
> I though of doing this, but passed in favor of simplicity of patch :)
> 
> The original made a specific point of doing
> 	gid_t group = cred->cr_groups[i];
> 	if (group == (gid_t) NOGROUP)
> 		break;
> 
> So the count loop should probably be
> 	ngroups = 0;
> 	if (!(exp->ex_flags & NFSEXP_ALLSQUASH)) {
> 		for (i = 0; i < SVC_CRED_NGROUPS; i++) {
> 			gid_t group = cred->cr_groups[i];
> 			if (group == (gid_t) NOGROUP)
> 				break;
> 			ngroups++;
> 		}
> 	}
> So that we don't assume anything about NOGROUP.

yes, thanks.

> > +	return ret;
> 
> The caller in fs/nfsd/nfsfh.c still needs to check the return value and do
> something with it, or all this is just dumb.

We can add that to Neil's todo list ;)


diff -puN fs/nfsd/auth.c~increase-NGROUPS-nfsd-cleanup-checks fs/nfsd/auth.c
--- 25/fs/nfsd/auth.c~increase-NGROUPS-nfsd-cleanup-checks	Fri Jan 30 15:03:55 2004
+++ 25-akpm/fs/nfsd/auth.c	Fri Jan 30 15:28:36 2004
@@ -11,13 +11,26 @@
 #include <linux/nfsd/nfsd.h>
 
 #define	CAP_NFSD_MASK (CAP_FS_MASK|CAP_TO_MASK(CAP_SYS_RESOURCE))
-void
-nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
+
+int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 {
 	struct svc_cred	*cred = &rqstp->rq_cred;
-	int		i, j;
-	gid_t		groups[SVC_CRED_NGROUPS];
 	struct group_info *group_info;
+	int ngroups;
+	int i;
+	int ret;
+
+	ngroups = 0;
+	if (!(exp->ex_flags & NFSEXP_ALLSQUASH)) {
+		for (i = 0; i < SVC_CRED_NGROUPS; i++) {
+			if (cred->cr_groups[i] == (gid_t)NOGROUP)
+				break;
+			ngroups++;
+		}
+	}
+	group_info = groups_alloc(ngroups);
+	if (group_info == NULL)
+		return -ENOMEM;
 
 	if (exp->ex_flags & NFSEXP_ALLSQUASH) {
 		cred->cr_uid = exp->ex_anon_uid;
@@ -41,25 +54,24 @@ nfsd_setuser(struct svc_rqst *rqstp, str
 		current->fsgid = cred->cr_gid;
 	else
 		current->fsgid = exp->ex_anon_gid;
+
 	for (i = 0; i < SVC_CRED_NGROUPS; i++) {
 		gid_t group = cred->cr_groups[i];
 		if (group == (gid_t) NOGROUP)
 			break;
-		groups[i] = group;
+		GROUP_AT(group_info, i) = group;
 	}
-	group_info = groups_alloc(i);
-	/* should be error checking, but we can't return ENOMEM! */
-	for (j = 0; j < i; j++)
-		GROUP_AT(group_info, j) = groups[j];
-	if (set_current_groups(group_info))
-		put_group_info(group_info);
-		/* should be error handling but we return void */
 
-	if ((cred->cr_uid)) {
-		cap_t(current->cap_effective) &= ~CAP_NFSD_MASK;
+	ret = set_current_groups(group_info);
+	if (ret == 0) {
+		if ((cred->cr_uid)) {
+			cap_t(current->cap_effective) &= ~CAP_NFSD_MASK;
+		} else {
+			cap_t(current->cap_effective) |= (CAP_NFSD_MASK &
+							current->cap_permitted);
+		}
 	} else {
-		cap_t(current->cap_effective) |= (CAP_NFSD_MASK &
-						  current->cap_permitted);
+		put_group_info(group_info);
 	}
-
+	return ret;
 }
diff -puN include/linux/nfsd/auth.h~increase-NGROUPS-nfsd-cleanup-checks include/linux/nfsd/auth.h
--- 25/include/linux/nfsd/auth.h~increase-NGROUPS-nfsd-cleanup-checks	Fri Jan 30 15:03:55 2004
+++ 25-akpm/include/linux/nfsd/auth.h	Fri Jan 30 15:03:55 2004
@@ -21,7 +21,7 @@
  * Set the current process's fsuid/fsgid etc to those of the NFS
  * client user
  */
-void		nfsd_setuser(struct svc_rqst *, struct svc_export *);
+int nfsd_setuser(struct svc_rqst *, struct svc_export *);
 
 #endif /* __KERNEL__ */
 #endif /* LINUX_NFSD_AUTH_H */

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
