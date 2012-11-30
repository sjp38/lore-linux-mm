Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 448976B0044
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 21:00:22 -0500 (EST)
Date: Fri, 30 Nov 2012 10:00:15 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [memcg:since-3.6 341/499]
 drivers/virtio/virtio_balloon.c:157:2-8: preceding lock on line 136
Message-ID: <20121130020015.GA29687@localhost>
References: <50b79f52.Rxsdi7iwHf+1mkK5%fengguang.wu@intel.com>
 <20121130002848.GA28177@localhost>
 <20121129164616.6c308ce0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121129164616.6c308ce0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rafael Aquini <aquini@redhat.com>, kbuild@01.org, Julia Lawall <julia.lawall@lip6.fr>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Thu, Nov 29, 2012 at 04:46:16PM -0800, Andrew Morton wrote:
> On Fri, 30 Nov 2012 08:28:48 +0800
> Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > Hi Rafael,
> > 
> > [Julia and me think that this coccinelle warning is worth reporting.]
> > 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
> > head:   422a0f651b5cefa1b6b3ede2e1c9e540a24a6e01
> > commit: 5f1da4063294480b3fabcee554f976565dec54b5 [341/499] virtio_balloon: introduce migration primitives to balloon pages
> > 
> > + drivers/virtio/virtio_balloon.c:157:2-8: preceding lock on line 136
> > 
> > vim +157 drivers/virtio/virtio_balloon.c
> > 
> > 6b35e407 Rusty Russell      2008-02-04  130  {
> > 5f1da406 Rafael Aquini      2012-11-09  131  	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
> > 5f1da406 Rafael Aquini      2012-11-09  132  
> > 6b35e407 Rusty Russell      2008-02-04  133  	/* We can only do one array worth at a time. */
> > 6b35e407 Rusty Russell      2008-02-04  134  	num = min(num, ARRAY_SIZE(vb->pfns));
> > 6b35e407 Rusty Russell      2008-02-04  135  
> > 5f1da406 Rafael Aquini      2012-11-09 @136  	mutex_lock(&vb->balloon_lock);
> > 3ccc9372 Michael S. Tsirkin 2012-04-12  137  	for (vb->num_pfns = 0; vb->num_pfns < num;
> > 3ccc9372 Michael S. Tsirkin 2012-04-12  138  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> > 5f1da406 Rafael Aquini      2012-11-09  139  		struct page *page = balloon_page_enqueue(vb_dev_info);
> > 5f1da406 Rafael Aquini      2012-11-09  140  
> > 6b35e407 Rusty Russell      2008-02-04  141  		if (!page) {
> > 6b35e407 Rusty Russell      2008-02-04  142  			if (printk_ratelimit())
> > 6b35e407 Rusty Russell      2008-02-04  143  				dev_printk(KERN_INFO, &vb->vdev->dev,
> > 6b35e407 Rusty Russell      2008-02-04  144  					   "Out of puff! Can't get %zu pages\n",
> > 5f1da406 Rafael Aquini      2012-11-09  145  					   VIRTIO_BALLOON_PAGES_PER_PAGE);
> > 6b35e407 Rusty Russell      2008-02-04  146  			/* Sleep for at least 1/5 of a second before retry. */
> > 6b35e407 Rusty Russell      2008-02-04  147  			msleep(200);
> > 6b35e407 Rusty Russell      2008-02-04  148  			break;
> > 6b35e407 Rusty Russell      2008-02-04  149  		}
> > 3ccc9372 Michael S. Tsirkin 2012-04-12  150  		set_page_pfns(vb->pfns + vb->num_pfns, page);
> > 3ccc9372 Michael S. Tsirkin 2012-04-12  151  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> > 6b35e407 Rusty Russell      2008-02-04  152  		totalram_pages--;
> > 6b35e407 Rusty Russell      2008-02-04  153  	}
> > 6b35e407 Rusty Russell      2008-02-04  154  
> > 6b35e407 Rusty Russell      2008-02-04  155  	/* Didn't get any?  Oh well. */
> > 6b35e407 Rusty Russell      2008-02-04  156  	if (vb->num_pfns == 0)
> > 6b35e407 Rusty Russell      2008-02-04 @157  		return;
> > 6b35e407 Rusty Russell      2008-02-04  158  
> > 6b35e407 Rusty Russell      2008-02-04  159  	tell_host(vb, vb->inflate_vq);
> > 5f1da406 Rafael Aquini      2012-11-09  160  	mutex_unlock(&vb->balloon_lock);
> 
> This bug was fixed by
> 
>             virtio_balloon-introduce-migration-primitives-to-balloon-pages.patch
> this one -> virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix.patch
>             virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix-fix.patch
>             virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix-fix-fix.patch

Michal: your since-3.6 branch somehow missed that followup fix...
 
> I'm surprised this sort of thing hasn't occurred before now - I'd
> assumed that your bisection system knew about the followup patches and
> skipped them.

Sure. I've been detecting and skipping your follow up fixes in the
"commit by commit" build test mode and the logic has been working
well, which is basically:

        [[ $(git_commit_subject $commit) =~ (fix|build|error|warning) ]] && return 0
        [[ $(git_commit_changelog $commit) =~ (build|compile|gcc|sparse|smatch|coccinelle|error|warning) ]] && return 0

Note that it's perfectly fine for the above logic to have false
positives. If ever a commit (which introduces a build error) is
skipped due to being falsely recognized as some followup fix, the
build error will still be detected in the next commit (or eventually,
in the HEAD which will always be build tested). bisect will then be
auto started and locate the error back to the skipped commit.

Note that the build system also runs a "check HEAD + bisect errors"
mode for some cases, in which it's not necessary to detect possible
fixup patches during bisect. Because if ever there is a working fix,
the error won't be able to show up in the branch HEAD at all, thus
bisect won't be started in the first place.

> I wonder how hard this is to do. My naming scheme is pretty simple:
> 
> foo-bar-zot.patch
> foo-bar-zot-[some-other-text].patch
> foo-bar-zot-[some-different-other-text].patch
> 
> But those are the local-to-mm filenames.  The Subject: field in the
> linux-next commit is sometimes quite different from the original
> filename.  But I can stop doing that, and ensure that the Subject:
> matches the filename for fixup patches.

I simply picked up the keyword "fix" in your typical name scheme
"XXXXXX-fix" ;-)

> That means that your are-there-any-fixup-patches logic would need to do
> this:
> 
> - Look at the patch title, For example, "virtio_balloon: introduce
>   migration primitives to balloon pages".
> 
> - Mangle that title into an akpm patch filename.  The dopey script I
>   use to do this is below.  In this example it will yield
>   virtio_balloon-introduce-migration-primitives-to-balloon-pages
> 
> - Look at the Subject: field of the following patches.  If they start
>   with virtio_balloon-introduce-migration-primitives-to-balloon-pages
>   then skip over them.
> 

Thanks for sharing the code and howto! It won't be hard for me to
follow that rule, however it seems a bit more straightforward to
detect the "fix" magic keyword in the subject line?

Thanks,
Fengguang

> #!/bin/sh
> . patchfns 2>/dev/null ||
> . /usr/lib/patch-scripts/patchfns 2>/dev/null ||
> . $PATCHSCRIPTS_LIBDIR/patchfns 2>/dev/null ||
> {
> 	echo "Impossible to find my library 'patchfns'."
> 	echo "Check your install, or go to the right directory"
> 	exit 1
> }
> 
> 
> line="$1"
> if stripit $line 2>/dev/null > /dev/null
> then
> 	f=$(stripit $line)
> 	if [ -e txt/$f.txt ]
> 	then
> 		line="$(grep "^Subject: " txt/$f.txt | head -n 1)"
> 		line=$(echo $line | sed -e "s/^Subject: //")
> 	fi
> fi
> 
> line=$(echo "$line" | tr 'A-Z' 'a-z')
> line=$(echo "$line" | sed -e 's/^subject:[ 	]*//')
> line=$(echo "$line" | sed -e 's/^fw:[ 	]*//')
> line=$(echo "$line" | sed -e 's/(fwd)//g')
> line=$(echo "$line" | sed -e 's/^fwd:[ 	]*//')
> line=$(echo "$line" | sed -e 's/^aw:[ 	]*//')
> line=$(echo "$line" | sed -e 's/^re:[ 	]*//')
> 
> line=$(echo "$line" | sed -e 's/^patch//')
> line=$(echo "$line" | sed -e "s/['\(\)\<\>\{\}\,\.\\]//g")
> line=$(echo "$line" | sed -e "s/[\#\*\&\+\^\!\~\`\|\?\;]//g")
> line=$(echo "$line" | sed -e "s/[\$]//g")
> line=$(echo "$line" | sed -e 's/"//g')
> line=$(echo "$line" | sed -e 's/^[-]*//g')
> line=$(echo "$line" | sed -e 's/\[[^]]*\]//g')
> line=$(echo "$line" | sed -e 's/[ 	]*\[patch\][	]*//')
> line=$(echo "$line" | sed -e 's/\[//g')
> line=$(echo "$line" | sed -e 's/\]//g')
> line=$(echo "$line" | sed -e 's/^[ 	]*//')
> line=$(echo "$line" | sed -e 's/ -/-/g')
> line=$(echo "$line" | sed -e 's/@/-/g')
> line=$(echo "$line" | sed -e 's/- /-/g')
> line=$(echo "$line" | sed -e 's/[ 	][ 	]*/-/g')
> line=$(echo "$line" | sed -e 's,/,-,g')
> line=$(echo "$line" | sed -e 's/--/-/g')
> line=$(echo "$line" | sed -e 's/-$//g')
> line=$(echo "$line" | sed -e 's/^-//g')
> line=$(echo "$line" | sed -e 's/:/-/g')
> 
> line=$(echo "$line" | sed -e 's/--/-/g')
> line=$(echo "$line" | sed -e 's/--/-/g')
> line=$(echo "$line" | sed -e 's/--/-/g')
> line=$(echo "$line" | sed -e 's/^[-]//')
> 
> line=$(echo "$line" | sed -e 's/[-]$//')
> line=$(echo "$line" | sed -e 's/[-]$//')
> line=$(echo "$line" | sed -e 's/[-]$//')
> 
> 
> echo "$line"
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
