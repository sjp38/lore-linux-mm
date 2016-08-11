Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC6D6B0253
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 19:13:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so17912460pfg.1
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 16:13:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 19si5401440pft.165.2016.08.11.16.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 16:13:40 -0700 (PDT)
Date: Thu, 11 Aug 2016 16:13:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mem-hotplug: introduce movablenode option
Message-Id: <20160811161335.8599521d14927394f1208fc7@linux-foundation.org>
In-Reply-To: <57A325CA.9050707@huawei.com>
References: <57A325CA.9050707@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 4 Aug 2016 19:23:54 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> This patch introduces a new boot option movablenode.
> 
> To support memory hotplug, boot option "movable_node" is needed. And to
> support debug memory hotplug, boot option "movable_node" and "movablenode"
> are both needed.
> 
> e.g. movable_node movablenode=1,2,4

I have some naming concerns.  "movable_node" and "movablenode" is just
confusing and ugly.

Can we just use the one parameter?   eg,

	vmlinux movable_node

or

	vmlinux movable_node=1,2,4

if not that, then how about "movable_node" and "movable_nodes"?  Then
every instance of "movablenode" in the patch itself should become
"movable_nodes" to be consistent with the command line parameter.

> It means node 1,2,4 will be set to movable nodes, the other nodes are
> unmovable nodes. Usually movable nodes are parsed from SRAT table which
> offered by BIOS, so this boot option is used for debug.
> 
>
> ---
>  Documentation/kernel-parameters.txt |  4 ++++
>  arch/x86/mm/srat.c                  | 36 ++++++++++++++++++++++++++++++++++++
>  2 files changed, 40 insertions(+)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 82b42c9..f8726f8 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2319,6 +2319,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  	movable_node	[KNL,X86] Boot-time switch to enable the effects
>  			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
>  
> +	movablenode=	[KNL,X86] Boot-time switch to set which node is
> +			movable node.
> +			Format: <movable nid>,...,<movable nid>

I think the docs should emphasize that this option disables the usual
SRAT-driven allocation and replaces it with manual allocation.

Also, can we please have more details in the patch changelog?  Why do we
*need* this?  Just for debugging?  Normally people will just use
SRAT-based allocation so normal users won't use this?  If so, why is
this debugging feature considered useful enough to add to the kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
