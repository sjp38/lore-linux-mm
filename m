Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B6ECA6B008C
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 01:34:17 -0500 (EST)
Received: by pwj10 with SMTP id 10so6652354pwj.6
        for <linux-mm@kvack.org>; Thu, 07 Jan 2010 22:34:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100107143651.2fa73662.randy.dunlap@oracle.com>
References: <201001072218.o07MIPNm020870@imap1.linux-foundation.org>
	 <20100107143651.2fa73662.randy.dunlap@oracle.com>
Date: Fri, 8 Jan 2010 12:34:15 +0600
Message-ID: <b9df5fa11001072234o2e5fb8bfv7b57a562d9a6e4d1@mail.gmail.com>
Subject: Re: + hugetlb-fix-section-mismatch-warning-in-hugetlbc.patch added to
	-mm tree
From: Rakib Mullick <rakib.mullick@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 1/8/10, Randy Dunlap <randy.dunlap@oracle.com> wrote:

Hi,
>
> Hi,
>
>  If so, then hugetlb_register_node() could be called at any time
>  (like after system init), and it would then call
>  hugetlb_sysfs_add_hstate(), which would be bad.
>
But - hugetlb_register_node is only called from hugetlb_register_all_nodes.
The call sequence is :
                    hugetlb_init   --------------->  was __init
                         \-> hugetlb_register_all_nodes  ----> we make it __init
                                          \-> hugetlb_register_node
---> we make it __init
                                                 \->
hugetlb_sysfs_add_hstate -> this was __init

Above all happens in __init context. So - hugetlb_register_node is
called only at
system init. But I don't think __init is used for hotplug support, for
proper hotplug
support we might use __meminit.

And register_hugetlbfs_with_node is called from hugetlb_un/register_node.
But hugetlb_unregister_node doesn't use callback function. It's not referencing
hugetlb_sysfs_add_hstate(). So - it's safe. Unless I'm not missing
anything, too.

thanks,

>  Thanks.
> ---
>
> ~Randy
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
