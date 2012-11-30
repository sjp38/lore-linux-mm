Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 96B056B0073
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 16:44:25 -0500 (EST)
Date: Sat, 1 Dec 2012 05:44:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [memcg:since-3.6 341/499]
 drivers/virtio/virtio_balloon.c:157:2-8: preceding lock on line 136
Message-ID: <20121130214418.GA20508@localhost>
References: <50b79f52.Rxsdi7iwHf+1mkK5%fengguang.wu@intel.com>
 <20121130002848.GA28177@localhost>
 <20121129164616.6c308ce0.akpm@linux-foundation.org>
 <20121130020015.GA29687@localhost>
 <20121130181459.GA20301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121130181459.GA20301@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rafael Aquini <aquini@redhat.com>, kbuild@01.org, Julia Lawall <julia.lawall@lip6.fr>, linux-mm@kvack.org

On Fri, Nov 30, 2012 at 07:14:59PM +0100, Michal Hocko wrote:
> On Fri 30-11-12 10:00:15, Wu Fengguang wrote:
> > On Thu, Nov 29, 2012 at 04:46:16PM -0800, Andrew Morton wrote:
> > > On Fri, 30 Nov 2012 08:28:48 +0800
> > > Fengguang Wu <fengguang.wu@intel.com> wrote:
> > > 
> > > > Hi Rafael,
> > > > 
> > > > [Julia and me think that this coccinelle warning is worth reporting.]
> > > > 
> > > > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
> > > > head:   422a0f651b5cefa1b6b3ede2e1c9e540a24a6e01
> > > > commit: 5f1da4063294480b3fabcee554f976565dec54b5 [341/499] virtio_balloon: introduce migration primitives to balloon pages
> > > > 
> > > > + drivers/virtio/virtio_balloon.c:157:2-8: preceding lock on line 136
> > > > 
> > > > vim +157 drivers/virtio/virtio_balloon.c
> > > > 
> > > > 6b35e407 Rusty Russell      2008-02-04  130  {
> > > > 5f1da406 Rafael Aquini      2012-11-09  131  	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
> > > > 5f1da406 Rafael Aquini      2012-11-09  132  
> > > > 6b35e407 Rusty Russell      2008-02-04  133  	/* We can only do one array worth at a time. */
> > > > 6b35e407 Rusty Russell      2008-02-04  134  	num = min(num, ARRAY_SIZE(vb->pfns));
> > > > 6b35e407 Rusty Russell      2008-02-04  135  
> > > > 5f1da406 Rafael Aquini      2012-11-09 @136  	mutex_lock(&vb->balloon_lock);
> > > > 3ccc9372 Michael S. Tsirkin 2012-04-12  137  	for (vb->num_pfns = 0; vb->num_pfns < num;
> > > > 3ccc9372 Michael S. Tsirkin 2012-04-12  138  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> > > > 5f1da406 Rafael Aquini      2012-11-09  139  		struct page *page = balloon_page_enqueue(vb_dev_info);
> > > > 5f1da406 Rafael Aquini      2012-11-09  140  
> > > > 6b35e407 Rusty Russell      2008-02-04  141  		if (!page) {
> > > > 6b35e407 Rusty Russell      2008-02-04  142  			if (printk_ratelimit())
> > > > 6b35e407 Rusty Russell      2008-02-04  143  				dev_printk(KERN_INFO, &vb->vdev->dev,
> > > > 6b35e407 Rusty Russell      2008-02-04  144  					   "Out of puff! Can't get %zu pages\n",
> > > > 5f1da406 Rafael Aquini      2012-11-09  145  					   VIRTIO_BALLOON_PAGES_PER_PAGE);
> > > > 6b35e407 Rusty Russell      2008-02-04  146  			/* Sleep for at least 1/5 of a second before retry. */
> > > > 6b35e407 Rusty Russell      2008-02-04  147  			msleep(200);
> > > > 6b35e407 Rusty Russell      2008-02-04  148  			break;
> > > > 6b35e407 Rusty Russell      2008-02-04  149  		}
> > > > 3ccc9372 Michael S. Tsirkin 2012-04-12  150  		set_page_pfns(vb->pfns + vb->num_pfns, page);
> > > > 3ccc9372 Michael S. Tsirkin 2012-04-12  151  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> > > > 6b35e407 Rusty Russell      2008-02-04  152  		totalram_pages--;
> > > > 6b35e407 Rusty Russell      2008-02-04  153  	}
> > > > 6b35e407 Rusty Russell      2008-02-04  154  
> > > > 6b35e407 Rusty Russell      2008-02-04  155  	/* Didn't get any?  Oh well. */
> > > > 6b35e407 Rusty Russell      2008-02-04  156  	if (vb->num_pfns == 0)
> > > > 6b35e407 Rusty Russell      2008-02-04 @157  		return;
> > > > 6b35e407 Rusty Russell      2008-02-04  158  
> > > > 6b35e407 Rusty Russell      2008-02-04  159  	tell_host(vb, vb->inflate_vq);
> > > > 5f1da406 Rafael Aquini      2012-11-09  160  	mutex_unlock(&vb->balloon_lock);
> > > 
> > > This bug was fixed by
> > > 
> > >             virtio_balloon-introduce-migration-primitives-to-balloon-pages.patch
> > > this one -> virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix.patch
> > >             virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix-fix.patch
> > >             virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix-fix-fix.patch
> > 
> > Michal: your since-3.6 branch somehow missed that followup fix...
> 
> Hmm strange, I can see all of them in my tree.
> 72d9876194be9e6f0600ca796b6689a77fce28b7
> f920c4f67b892a6b41054c5441ab0d481489c6c9
> 63db42f4243be26efffc32806990349235619bad

Oops.. the fixes are reverted by a later commit 4f2ac849

        -       /* Did we get any? */
        -       if (vb->num_pfns != 0)
        -               tell_host(vb, vb->inflate_vq);
        -       mutex_unlock(&vb->balloon_lock);
        +       /* Didn't get any?  Oh well. */
(*)     +       if (vb->num_pfns == 0)
(*)     +               return;
        +
        +       tell_host(vb, vb->inflate_vq);

(*) then we got the coccinelle warning again in the HEAD.

Thanks,
Fengguang

> merged in mmotm-2012-11-14-17-40
> 
> and my mis-merge follow-up
> 83bb61967444e22100f7c6e2a5f79ffa85b9e981
> 
> merged in mmotm-2012-11-26-17-32
> All of them should be 
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
