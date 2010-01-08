Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9B43B6B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 09:06:37 -0500 (EST)
Subject: Re: + hugetlb-fix-section-mismatch-warning-in-hugetlbc.patch added
 to  -mm tree
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <b9df5fa11001072234o2e5fb8bfv7b57a562d9a6e4d1@mail.gmail.com>
References: <201001072218.o07MIPNm020870@imap1.linux-foundation.org>
	 <20100107143651.2fa73662.randy.dunlap@oracle.com>
	 <b9df5fa11001072234o2e5fb8bfv7b57a562d9a6e4d1@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 08 Jan 2010 09:06:09 -0500
Message-Id: <1262959569.24795.22.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rakib Mullick <rakib.mullick@gmail.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-01-08 at 12:34 +0600, Rakib Mullick wrote:
> On 1/8/10, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
> Hi,
> >
> > Hi,
> >
> >  If so, then hugetlb_register_node() could be called at any time
> >  (like after system init), and it would then call
> >  hugetlb_sysfs_add_hstate(), which would be bad.
> >
> But - hugetlb_register_node is only called from hugetlb_register_all_nodes.

No, hugetlb_register_node() is also called from the similarly named
function in drivers/base/node.c.   mm/hugetlb.c registers its version of
"hugetlb_register_node()" at start up for use at node hotplug.  See
register_hugetlbfs_with_node() in node.c and its use in hugetlb.c.

We had to do it this way because node.c is part of the base kernel and
hugetlb support can be built as a module.  All sysfs node kobjs have
been registered by the time hugetlb inits, so hugetlb registers the
nodes' hstate attributes when it initializes.  However, when a node is
hotplugged later, the node driver calls into hugetlb to register the
attributes.

So, we need to keep mm/hugetlb.c:hugetlb_register_node() around during
run time when mem/node hot-plug is supported.

Lee


> The call sequence is :
>                     hugetlb_init   --------------->  was __init
>                          \-> hugetlb_register_all_nodes  ----> we make it __init
>                                           \-> hugetlb_register_node
> ---> we make it __init
>                                                  \->
> hugetlb_sysfs_add_hstate -> this was __init
> 
> Above all happens in __init context. So - hugetlb_register_node is
> called only at
> system init. But I don't think __init is used for hotplug support, for
> proper hotplug
> support we might use __meminit.
> 
> And register_hugetlbfs_with_node is called from hugetlb_un/register_node.
> But hugetlb_unregister_node doesn't use callback function. It's not referencing
> hugetlb_sysfs_add_hstate(). So - it's safe. Unless I'm not missing
> anything, too.
> 
> thanks,
> 
> >  Thanks.
> > ---
> >
> > ~Randy
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
