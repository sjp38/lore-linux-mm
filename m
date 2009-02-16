Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C71DD6B00AA
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:31:43 -0500 (EST)
Date: Mon, 16 Feb 2009 16:33:51 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 6/8] cifs: use kzfree()
Message-ID: <20090216153351.GB27520@cmpxchg.org>
References: <20090216142926.440561506@cmpxchg.org> <20090216144725.976425091@cmpxchg.org> <84144f020902160713y7341b2b4g8aa10919405ab82d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020902160713y7341b2b4g8aa10919405ab82d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve French <sfrench@samba.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 16, 2009 at 05:13:30PM +0200, Pekka Enberg wrote:
> Hi Johannes,
> 
> On Mon, Feb 16, 2009 at 4:29 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > @@ -2433,11 +2433,8 @@ mount_fail_check:
> >  out:
> >        /* zero out password before freeing */
> >        if (volume_info) {
> > -               if (volume_info->password != NULL) {
> > -                       memset(volume_info->password, 0,
> > -                               strlen(volume_info->password));
> > -                       kfree(volume_info->password);
> > -               }
> > +               if (volume_info->password != NULL)
> > +                       kzfree(volume_info->password);
> 
> The NULL check here is unnecessary.
> 
> >                kfree(volume_info->UNC);
> >                kfree(volume_info->prepath);
> >                kfree(volume_info);
> > --- a/fs/cifs/misc.c
> > +++ b/fs/cifs/misc.c
> > @@ -97,10 +97,8 @@ sesInfoFree(struct cifsSesInfo *buf_to_f
> >        kfree(buf_to_free->serverOS);
> >        kfree(buf_to_free->serverDomain);
> >        kfree(buf_to_free->serverNOS);
> > -       if (buf_to_free->password) {
> > -               memset(buf_to_free->password, 0, strlen(buf_to_free->password));
> > -               kfree(buf_to_free->password);
> > -       }
> > +       if (buf_to_free->password)
> > +               kzfree(buf_to_free->password);
> 
> And here.

Thanks, Pekka!

Here is the delta to fold into the above:

[ btw, do these require an extra SOB?  If so:
  Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

  And for http://lkml.org/lkml/2009/2/16/184:
  Signed-off-by: Johannes Weiner <hannes@cmpxchg.org> ]

--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -2433,8 +2433,7 @@ mount_fail_check:
 out:
 	/* zero out password before freeing */
 	if (volume_info) {
-		if (volume_info->password != NULL)
-			kzfree(volume_info->password);
+		kzfree(volume_info->password);
 		kfree(volume_info->UNC);
 		kfree(volume_info->prepath);
 		kfree(volume_info);
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -97,8 +97,7 @@ sesInfoFree(struct cifsSesInfo *buf_to_f
 	kfree(buf_to_free->serverOS);
 	kfree(buf_to_free->serverDomain);
 	kfree(buf_to_free->serverNOS);
-	if (buf_to_free->password)
-		kzfree(buf_to_free->password);
+	kzfree(buf_to_free->password);
 	kfree(buf_to_free->domainName);
 	kfree(buf_to_free);
 }
@@ -130,8 +129,7 @@ tconInfoFree(struct cifsTconInfo *buf_to
 	}
 	atomic_dec(&tconInfoAllocCount);
 	kfree(buf_to_free->nativeFileSystem);
-	if (buf_to_free->password)
-		kzfree(buf_to_free->password);
+	kzfree(buf_to_free->password);
 	kfree(buf_to_free);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
