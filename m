Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 918746B006E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 20:06:14 -0400 (EDT)
Received: by igbzc4 with SMTP id zc4so23723690igb.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:06:14 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0070.hostedemail.com. [216.40.44.70])
        by mx.google.com with ESMTP id ba5si7602031icc.39.2015.06.09.17.06.14
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 17:06:14 -0700 (PDT)
Message-ID: <1433894769.2730.87.camel@perches.com>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
From: Joe Perches <joe@perches.com>
Date: Tue, 09 Jun 2015 17:06:09 -0700
In-Reply-To: <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
	 <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <julia.lawall@lip6.fr>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Tue, 2015-06-09 at 14:25 -0700, Andrew Morton wrote:
> On Tue,  9 Jun 2015 21:04:48 +0900 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:
> 
> > The existing pools' destroy() functions do not allow NULL pool pointers;
> > instead, every destructor() caller forced to check if pool is not NULL,
> > which:
> >  a) requires additional attention from developers/reviewers
> >  b) may lead to a NULL pointer dereferences if (a) didn't work
> > 
> > 
> > First 3 patches tweak
> > - kmem_cache_destroy()
> > - mempool_destroy()
> > - dma_pool_destroy()
> > 
> > to handle NULL pointers.
> 
> Well I like it, even though it's going to cause a zillion little cleanup
> patches.
> 
> checkpatch already has a "kfree(NULL) is safe and this check is
> probably not required" test so I guess Joe will need to get busy ;)

Maybe it'll be Julia's crew.

The checkpatch change is pretty trivial
---
 scripts/checkpatch.pl | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 69c4716..3d6e34d 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -4801,7 +4801,7 @@ sub process {
 # check for needless "if (<foo>) fn(<foo>)" uses
 		if ($prevline =~ /\bif\s*\(\s*($Lval)\s*\)/) {
 			my $expr = '\s*\(\s*' . quotemeta($1) . '\s*\)\s*;';
-			if ($line =~ /\b(kfree|usb_free_urb|debugfs_remove(?:_recursive)?)$expr/) {
+			if ($line =~ /\b(kfree|usb_free_urb|debugfs_remove(?:_recursive)?|(?:kmem_cache|mempool|dma_pool)_destroy)$expr/) {
 				WARN('NEEDLESS_IF',
 				     "$1(NULL) is safe and this check is probably not required\n" . $hereprev);
 			}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
