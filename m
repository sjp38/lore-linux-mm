Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7656B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 23:31:49 -0400 (EDT)
Received: by qkfh127 with SMTP id h127so60710820qkf.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 20:31:49 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id m84si26211277qki.115.2015.08.23.20.31.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Aug 2015 20:31:48 -0700 (PDT)
Message-ID: <55DA8F59.1050700@huawei.com>
Date: Mon, 24 Aug 2015 11:28:25 +0800
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

Hi Rik,

Thank you for your reply. I find the reason is this patch,
and it is not backport to RedHat 7.0

8790c71a18e5d2d93532ae250bcf5eddbba729cd

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 873de7e..ae3c8f3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2930,7 +2930,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
        unsigned short mode = MPOL_DEFAULT;
        unsigned short flags = 0;

-       if (pol && pol != &default_policy) {
+       if (pol && pol != &default_policy && !(pol->flags & MPOL_F_MORON)) {
                mode = pol->mode;
                flags = pol->flags;
        }

Thanks,
Xishi Qiu

> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
