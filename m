Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 66C686B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:23:42 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so87101275pac.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 21:23:42 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id ae4si25462537pac.2.2015.08.23.21.18.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Aug 2015 21:23:41 -0700 (PDT)
Message-ID: <55DA9A4B.10203@huawei.com>
Date: Mon, 24 Aug 2015 12:15:07 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: is this a problem of numactl in RedHat7.0 ?
References: <55D6EEEB.7050701@huawei.com> <55D78FB0.9040906@redhat.com>
In-Reply-To: <55D78FB0.9040906@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xiexiuqi <xiexiuqi@huawei.com>

On 2015/8/22 4:53, Rik van Riel wrote:

> On 08/21/2015 05:27 AM, Xishi Qiu wrote:
>> I use numactl(--localalloc) tool run a test case, but it shows that
>> the numa policy is prefer, I don't know why.
> 
> The kernel implements MPOL_PREFERRED and MPOL_LOCAL
> in the same way. Look at this code in mpol_new(),
> in mm/mempolicy.c:
> 

user:
"numactl --localalloc" wil call
	main()
	  numa_set_localalloc()
	    setpol(MPOL_DEFAULT, numa_no_nodes_ptr);
	      set_mempolicy()
	        syscall(__NR_set_mempolicy,mode,nmask,maxnode);

kernel:
	do_set_mempolicy()
	  mpol_new()
		if (mode == MPOL_DEFAULT) {
			if (nodes && !nodes_empty(*nodes))
				return ERR_PTR(-EINVAL);
			return NULL;  // return from here
		}

>         /*
>          * MPOL_PREFERRED cannot be used with MPOL_F_STATIC_NODES or
>          * MPOL_F_RELATIVE_NODES if the nodemask is empty (local allocation).
>          * All other modes require a valid pointer to a non-empty nodemask.
>          */
>         if (mode == MPOL_PREFERRED) {
>                 if (nodes_empty(*nodes)) {
>                         if (((flags & MPOL_F_STATIC_NODES) ||
>                              (flags & MPOL_F_RELATIVE_NODES)))
>                                 return ERR_PTR(-EINVAL);
>                 }
>         } else if (mode == MPOL_LOCAL) {
>                 if (!nodes_empty(*nodes))
>                         return ERR_PTR(-EINVAL);
>                 mode = MPOL_PREFERRED;
>         } else if (nodes_empty(*nodes))
>                 return ERR_PTR(-EINVAL);
> 
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
