Date: Tue, 1 May 2007 16:46:51 +0200
From: Adrian Bunk <bunk@stusta.de>
Subject: Re: pcmcia ioctl removal
Message-ID: <20070501144650.GB3531@stusta.de>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501084623.GB14364@infradead.org> <20070501085710.GA13488@1wt.eu> <20070501020820.05f0c037.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20070501020820.05f0c037.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Willy Tarreau <w@1wt.eu>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, May 01, 2007 at 02:08:20AM -0700, Andrew Morton wrote:
> On Tue, 1 May 2007 10:57:10 +0200 Willy Tarreau <w@1wt.eu> wrote:
> 
> > Hi Christoph,
> > 
> > On Tue, May 01, 2007 at 09:46:23AM +0100, Christoph Hellwig wrote:
> > > >  pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch
> > > 
> > > ...
> > > 
> > > > Dominik is busy.  Will probably re-review and send these direct to Linus.
> > > 
> > > The patch above is the removal of cardmgr support.  While I'd love to
> > > see this cruft gone it definitively needs maintainer judgement on whether
> > > they time has come that no one relies on cardmgr anymore.
> > 
> > Well, I've not followed evolutions in this area for a long time. Here's
> > what I get on my notebook :
> > 
> > willy@wtap:~$ uname -r
> > 2.6.20-wt3-wtap
> > willy@wtap:~$ ps auxw|grep card   
> > root      1216  0.0  0.0     0    0 ?        S<   Apr28   0:00 [pccardd]
> > root      1221  0.0  0.0     0    0 ?        S<   Apr28   0:00 [pccardd]
> > root      1244  0.0  0.0     0    0 ?        S<   Apr28   0:00 [pccardd]
> > root      1251  0.0  0.0     0    0 ?        Ss   Apr28   0:00 /sbin/cardmgr
> > 
> 
> Yes, that seems premature.  feature-removal.txt is pretty useless for
> getting poeple off old tools.  If we're ever to make this migration we'll
> need loud and scary printks coming out of the kernel.  Probably it'll take
> another year or two to get there *once* we've done that.


You already said the same two years ago, and you forwarded a patch 
implementing exactly this nearly two years ago:


commit c352ec8ab87b065cd2edda171811f49ac7d0d5cd
Author: Dominik Brodowski <linux@dominikbrodowski.net>
Date:   Tue Sep 13 01:25:03 2005 -0700

    [PATCH] pcmcia: warn on IOCTL usage
    
    More visible user information of scheduled feature removal.
    
    Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

diff --git a/drivers/pcmcia/pcmcia_ioctl.c b/drivers/pcmcia/pcmcia_ioctl.c
index 39ba640..80969f7 100644
--- a/drivers/pcmcia/pcmcia_ioctl.c
+++ b/drivers/pcmcia/pcmcia_ioctl.c
@@ -376,6 +376,7 @@ static int ds_open(struct inode *inode, struct file *file)
     socket_t i = iminor(inode);
     struct pcmcia_socket *s;
     user_info_t *user;
+    static int warning_printed = 0;
 
     ds_dbg(0, "ds_open(socket %d)\n", i);
 
@@ -407,6 +408,17 @@ static int ds_open(struct inode *inode, struct file *file)
     s->user = user;
     file->private_data = user;
 
+    if (!warning_printed) {
+	    printk(KERN_INFO "pcmcia: Detected deprecated PCMCIA ioctl "
+			"usage.\n");
+	    printk(KERN_INFO "pcmcia: This interface will soon be removed from "
+			"the kernel; please expect breakage unless you upgrade "
+			"to new tools.\n");
+	    printk(KERN_INFO "pcmcia: see http://www.kernel.org/pub/linux/"
+			"utils/kernel/pcmcia/pcmcia.html for details.\n");
+	    warning_printed = 1;
+    }
+
     if (s->pcmcia_state.present)
 	queue_event(user, CS_EVENT_CARD_INSERTION);
     return 0;


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
