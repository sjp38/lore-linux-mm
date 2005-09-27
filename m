Date: Mon, 26 Sep 2005 22:44:39 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/9] add defrag flags
Message-Id: <20050926224439.056eaf8d.pj@sgi.com>
In-Reply-To: <1127780648.10315.12.camel@localhost>
References: <4338537E.8070603@austin.ibm.com>
	<43385412.5080506@austin.ibm.com>
	<21024267-29C3-4657-9C45-17D186EAD808@mac.com>
	<1127780648.10315.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: mrmacman_g4@mac.com, jschopp@austin.ibm.com, akpm@osdl.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

Dave wrote:
> I think Joel simply made an error in his description.

Looks like he made the same mistake in the actual code comments:

+/* Allocation type modifiers, group together if possible
+ * __GPF_USER: Allocation for user page or a buffer page
+ * __GFP_KERNRCLM: Short-lived or reclaimable kernel allocation
+ */
+#define __GFP_USER	0x40000u /* Kernel page that is easily reclaimable */
+#define __GFP_KERNRCLM	0x80000u /* User is a userspace user */

I'd guess you meant to write more like the following:

#define __GFP_USER   0x40000u /* Page for user address space */
#define __GFP_KERNRCLM 0x80000u /* Kernel page that is easily reclaimable */

And the block comment seems to needlessly repeat the inline comments,
add a dubious claim, and omit the interesting stuff ...  In other words:

    Does it actually matter if these two bits are grouped, or not?  I
    suspect that some of your other code, such as shifting the gfpmask by
    RCLM_SHIFT bits, _requires_ that these two bits be adjacent.  So the
    "if possible" in the comment above is misleading.

    And I suspect that gfp.h should contain the RCLM_SHIFT define, or
    at least mention in comment that RCLM_SHIFT depends on the position
    of the above two __GFP_* bits.

    And I don't see any mention in the comments in gfp.h that these
    two bits, in tandem, have an additional meaning - both bits off
    means, I guess, not reclaimable, well at least not easily.

My HARDWALL patch appears to already be in Linus's kernel, so you
probably also need to do a global substitute of all instances in
the kernel of __GFP_HARDWALL, replacing it with __GFP_USER.  Here
is the list of files I see affected, with a count of the number of
__GFP_HARDWALL strings in each:

    include/linux/gfp.h:4
    kernel/cpuset.c:6
    mm/page_alloc.c:2
    mm/vmscan.c:4

The comment in the next line looks like it needs to be changed to match
the code change:

+#define __GFP_BITS_SHIFT 21	/* Room for 20 __GFP_FOO bits */

On the other hand, why did you change __GFP_BITS_SHIFT?  Isn't 20
enough - just enough?

Why was the flag change in fs/buffer.c:grow_dev_page() to add the
__GFP_USER bit, not to add the __GFP_KERNRCLM bit?  I don't know that
code - perhaps the answer is simply that the resulting page ends up in
user space.

Aha - I just read one of the comments above that I cut+pasted.
It says that __GFP_USER means user *OR* buffer page.  That certainly
explains the fs/buffer.c code using __GFP_USER.  But it causes me to
wonder if we can equate __GFP_USER with __GFP_HARDWALL.  I'm reluctant,
but more on principal than concrete experience, to modify the meaning
of hardwall cpusets to constrain both user address space pages *AND*
buffer pages.  How open would you be to making buffers __GFP_KERNRCLM
instead of __GFP_USER?

If you have good reason to keep __GFP_USER meanin either user or buffer,
then perhaps the name __GFP_USER is misleading.

What sort of performance claims can you make for this change?  How does
it impact kernel text size?  Could we see a diffstat for the entire
patchset?  Under what sort of loads or conditions would you expect
this patchset to do more harm than good?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
