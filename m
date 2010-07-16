Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 987186B02A3
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 14:45:52 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GIaBXk005892
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 12:36:11 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6GIjXDT130698
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 12:45:35 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GIjXh3009162
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 12:45:33 -0600
Subject: Re: [PATCH 1/5] v2 Split the memory_block structure
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C40A3BC.3060504@austin.ibm.com>
References: <4C3F53D1.3090001@austin.ibm.com>
	 <4C3F557F.3000304@austin.ibm.com> <1279300521.9207.222.camel@nimitz>
	 <4C40A3BC.3060504@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 16 Jul 2010 11:45:31 -0700
Message-ID: <1279305931.9207.265.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-07-16 at 13:23 -0500, Nathan Fontenot wrote:
> >> -    if (mem->state != from_state_req) {
> >> -            ret = -EINVAL;
> >> -            goto out;
> >> +    list_for_each_entry(mbs, &mem->sections, next) {
> >> +            if (mbs->state != from_state_req)
> >> +                    continue;
> >> +
> >> +            ret = memory_block_action(mbs, to_state);
> >> +            if (ret)
> >> +                    break;
> >> +    }
> >> +
> >> +    if (ret) {
> >> +            list_for_each_entry(mbs, &mem->sections, next) {
> >> +                    if (mbs->state == from_state_req)
> >> +                            continue;
> >> +
> >> +                    if (memory_block_action(mbs, to_state))
> >> +                            printk(KERN_ERR "Could not re-enable memory "
> >> +                                   "section %lx\n", mbs->phys_index);
> >> +            }
> >>      }
> > 
> > Please just use a goto here.  It's nicer looking, and much more in line
> > with what's there already.
> 
> Not sure if I follow on where you want the goto.  If you mean after the
> if (memory_block_action())...  I purposely did not have a goto here.
> Since this is in the recovery path I wanted to make sure we tried to return
> every memory section to the original state. 

Looking at it a little closer, I see what you're doing now.

First of all, should memory_block_action() get a new name since it isn
not taking 'memory_block_section's?

The thing I would have liked to see is to have that error handling block
out of the way a bit.  But, the function is small, and there's not _too_
much code in there, so what you have is probably the best way to do it.

Minor nit: Please pull the memory_block_action() out of the if() and do
the:

> >> +            ret = memory_block_action(mbs, to_state);
> >> +            if (ret)
> >> +                    break;

thing like above.  It makes it much more obvious that the loop is
related to the top one.  I was thinking if it made sense to have a
helper function to go through and do that list walk, so you could do:

	ret = set_all_states(mem->sections, to_state);
	if (ret)
		set_all_states(mem->sections, old_state);

But I think you'd need to pass in a bit more information, so it probably
isn't worth doing that, either.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
