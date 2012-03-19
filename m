Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id C010B6B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 13:28:38 -0400 (EDT)
Message-ID: <1332178095.18960.354.camel@twins>
Subject: Re: [RFC][PATCH 10/26] mm, mpol: Make mempolicy home-node aware
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 19 Mar 2012 18:28:15 +0100
In-Reply-To: <1332176969.18960.351.camel@twins>
References: <20120316144028.036474157@chello.nl>
	 <20120316144240.763518310@chello.nl>
	 <alpine.DEB.2.00.1203161333370.10211@router.home>
	 <1331932375.18960.237.camel@twins>
	 <alpine.DEB.2.00.1203190852380.16879@router.home>
	 <1332165959.18960.340.camel@twins>
	 <alpine.DEB.2.00.1203191012530.17008@router.home>
	 <1332170628.18960.349.camel@twins>
	 <alpine.DEB.2.00.1203191029090.19189@router.home>
	 <1332176969.18960.351.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 18:09 +0100, Peter Zijlstra wrote:
> On Mon, 2012-03-19 at 10:31 -0500, Christoph Lameter wrote:
>=20
> > MPOL_DEFAULT is a certain type of behavior right now that applications
> > rely on. If you change that then these applications will no longer work=
 as
> > expected.
> >=20
> > MPOL_DEFAULT is currently set to be the default policy on bootup. You c=
an
> > change that of course and allow setting MPOL_DEFAULT manually for
> > applications that rely on old behavor. Instead set the default behavior=
 on
> > bootup for MPOL_HOME_NODE.
> >=20
> > So the default system behavior would be MPOL_HOME_NODE but it could be
> > overriding by numactl to allow old apps to run as they are used to run.
>=20
> Ah, OK. Although that's a mightily confusing usage of the word DEFAULT.
> How about instead we make MPOL_LOCAL a real policy and allow explicitly
> setting that?

I suspect something like the below might suffice.. still need to test it
though.

---
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -21,6 +21,7 @@ enum {
 	MPOL_BIND,
 	MPOL_INTERLEAVE,
 	MPOL_NOOP,		/* retain existing policy for range */
+	MPOL_LOCAL,
 	MPOL_MAX,	/* always last member of enum */
 };
=20
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -285,6 +285,10 @@ struct mempolicy *mpol_new(unsigned shor
 			     (flags & MPOL_F_RELATIVE_NODES)))
 				return ERR_PTR(-EINVAL);
 		}
+	} else if (mode =3D=3D MPOL_LOCAL) {
+		if (!nodes_empty(*nodes))
+			return ERR_PTR(-EINVAL);
+		mode =3D MPOL_PREFERRED;
 	} else if (nodes_empty(*nodes))
 		return ERR_PTR(-EINVAL);
 	policy =3D kmem_cache_alloc(policy_cache, GFP_KERNEL | __GFP_ZERO);
@@ -2446,7 +2450,6 @@ void numa_default_policy(void)
  * "local" is pseudo-policy:  MPOL_PREFERRED with MPOL_F_LOCAL flag
  * Used only for mpol_parse_str() and mpol_to_str()
  */
-#define MPOL_LOCAL MPOL_MAX
 static const char * const policy_modes[] =3D
 {
 	[MPOL_DEFAULT]    =3D "default",
@@ -2499,12 +2502,12 @@ int mpol_parse_str(char *str, struct mem
 	if (flags)
 		*flags++ =3D '\0';	/* terminate mode string */
=20
-	for (mode =3D 0; mode <=3D MPOL_LOCAL; mode++) {
+	for (mode =3D 0; mode < MPOL_MAX; mode++) {
 		if (!strcmp(str, policy_modes[mode])) {
 			break;
 		}
 	}
-	if (mode > MPOL_LOCAL)
+	if (mode >=3D MPOL_MAX)
 		goto out;
=20
 	switch (mode) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
