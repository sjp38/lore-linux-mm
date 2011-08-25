Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E15AC6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 11:45:48 -0400 (EDT)
Date: Thu, 25 Aug 2011 17:45:38 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: mmotm 2011-08-24-14-08 uploaded
Message-ID: <20110825154538.GA5860@redhat.com>
References: <201108242148.p7OLm1lt009191@imap1.linux-foundation.org>
 <20110825135103.GA6431@tiehlicka.suse.cz>
 <20110825140701.GA6838@tiehlicka.suse.cz>
 <20110826010938.5795e43137d58c9f42d44458@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110826010938.5795e43137d58c9f42d44458@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Fri, Aug 26, 2011 at 01:09:38AM +1000, Stephen Rothwell wrote:
> Hi,
> 
> On Thu, 25 Aug 2011 16:07:01 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> >
> > On Thu 25-08-11 15:51:03, Michal Hocko wrote:
> > > 
> > > On Wed 24-08-11 14:09:05, Andrew Morton wrote:
> > > > The mm-of-the-moment snapshot 2011-08-24-14-08 has been uploaded to
> > > > 
> > > >    http://userweb.kernel.org/~akpm/mmotm/
> > > 
> > > I have just downloaded your tree and cannot quilt it up. I am getting:
> > > [...]
> > > patching file tools/power/cpupower/debug/x86_64/centrino-decode.c
> > > Hunk #1 FAILED at 1.
> > > File tools/power/cpupower/debug/x86_64/centrino-decode.c is not empty after patch, as expected
> > > 1 out of 1 hunk FAILED -- rejects in file tools/power/cpupower/debug/x86_64/centrino-decode.c
> > > patching file tools/power/cpupower/debug/x86_64/powernow-k8-decode.c
> > > Hunk #1 FAILED at 1.
> > > File tools/power/cpupower/debug/x86_64/powernow-k8-decode.c is not empty after patch, as expected
> > > 1 out of 1 hunk FAILED -- rejects in file tools/power/cpupower/debug/x86_64/powernow-k8-decode.c
> > > [...]
> > > patching file virt/kvm/iommu.c
> > > Patch linux-next.patch does not apply (enforce with -f)
> > > 
> > > Is this a patch (I am using 2.6.1) issue? The failing hunk looks as
> > > follows:
> > > --- a/tools/power/cpupower/debug/x86_64/centrino-decode.c
> > > +++ /dev/null
> > > @@ -1 +0,0 @@
> > > -../i386/centrino-decode.c
> > > \ No newline at end of file
> > 
> > Isn't this just a special form of git (clever) diff to spare some lines
> > when the file deleted? Or is the patch simply corrupted?
> > Anyway, my patch doesn't cope with that. Any hint what to do about it?
> 
> Those files were symlinks and were removed by a commit in linux-next.
> diff/patch does not cope with that.

You can probably replace `patch' in your $PATH by a wrapper that uses
git-apply, which can deal with them.

Or you could use git-quiltimport, which uses git-apply, to prepare the
-mmotm base tree in git, on top of which you can continue to work with
quilt.

I do this with a cron-job automatically, you can find the result here:

    http://git.kernel.org/?p=linux/kernel/git/hannes/linux-mmotm.git;a=summary

If you want to do it manually, there is sometimes confusing binary
file patch sections in -mmotm, which in turn git-apply can not deal
with, so I use the following uncrapdiff.awk filter on the patches
before import.

---

# Filter out sections that feature an index line but
# no real diff part that would start with '--- file'

{
	if (HEADER ~ /^diff --git /) {
		if ($0 ~ /^index /) {
			INDEX=$0
		} else if ($0 ~ /^diff --git /) {
			print(HEADER)
			HEADER=$0
		} else if (INDEX ~ /^index /) {
			if ($0 ~ /^--- /) {
				print(HEADER)
				print(INDEX)
				print($0)
			}
			HEADER=""
			INDEX=""
		} else {
			HEADER=HEADER "\n" $0
		}
	} else if ($0 ~ /^diff --git /) {
		HEADER=$0
	} else {
		print($0)
	}
}

---

HTH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
