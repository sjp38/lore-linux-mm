Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id A81AE6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 16:53:13 -0400 (EDT)
Received: by qgeb6 with SMTP id b6so54117173qge.3
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 13:53:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r137si10493731qha.16.2015.08.21.13.53.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 13:53:13 -0700 (PDT)
Message-ID: <55D78FB0.9040906@redhat.com>
Date: Fri, 21 Aug 2015 16:53:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: is this a problem of numactl in RedHat7.0 ?
References: <55D6EEEB.7050701@huawei.com>
In-Reply-To: <55D6EEEB.7050701@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Xiexiuqi <xiexiuqi@huawei.com>

On 08/21/2015 05:27 AM, Xishi Qiu wrote:
> I use numactl(--localalloc) tool run a test case, but it shows that
> the numa policy is prefer, I don't know why.

The kernel implements MPOL_PREFERRED and MPOL_LOCAL
in the same way. Look at this code in mpol_new(),
in mm/mempolicy.c:

         /*
          * MPOL_PREFERRED cannot be used with MPOL_F_STATIC_NODES or
          * MPOL_F_RELATIVE_NODES if the nodemask is empty (local 
allocation).
          * All other modes require a valid pointer to a non-empty nodemask.
          */
         if (mode == MPOL_PREFERRED) {
                 if (nodes_empty(*nodes)) {
                         if (((flags & MPOL_F_STATIC_NODES) ||
                              (flags & MPOL_F_RELATIVE_NODES)))
                                 return ERR_PTR(-EINVAL);
                 }
         } else if (mode == MPOL_LOCAL) {
                 if (!nodes_empty(*nodes))
                         return ERR_PTR(-EINVAL);
                 mode = MPOL_PREFERRED;
         } else if (nodes_empty(*nodes))
                 return ERR_PTR(-EINVAL);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
