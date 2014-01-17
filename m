Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5996B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 13:08:37 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id w8so3598969qac.28
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 10:08:36 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id h49si2869902qgf.9.2014.01.17.10.08.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 10:08:27 -0800 (PST)
From: "Strashko, Grygorii" <grygorii.strashko@ti.com>
Subject: RE: [PATCH V3 2/2] mm/memblock: Add support for excluded memory
 areas
Date: Fri, 17 Jan 2014 18:08:13 +0000
Message-ID: <902E09E6452B0E43903E4F2D568737AB0B9852BA@DFRE01.ent.ti.com>
References: <1389618217-48166-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
	<52D538FD.8010907@ti.com>,<20140114195225.078f810a@lilie>
In-Reply-To: <20140114195225.078f810a@lilie>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "daeseok.youn@gmail.com" <daeseok.youn@gmail.com>, "liuj97@gmail.com" <liuj97@gmail.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "Shilimkar,
 Santosh" <santosh.shilimkar@ti.com>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Philipp,=0A=
=0A=
On 01/14/2014 08:52 PM, Philipp Hachtmann wrote:=0A=
> Hello Grygorii,=0A=
> =0A=
> thank you for your comments.=0A=
> =0A=
> To clarify we have the following requirements for memblock:=0A=
> =0A=
> (1) Reserved areas can be declared before memory is added.=0A=
> (2) The physical memory is detected once only.=0A=
> (3) The free memory (i.e. not reserved) memory can be iterated to add=0A=
> it to the buddy allocator.=0A=
> (4) Memory designated to be mapped into the kernel address space can be=
=0A=
> iterated.=0A=
> (5) Kdump on s390 requires knowledge about the full system memory=0A=
> layout.=0A=
> =0A=
> The s390 kdump implementation works a bit different from the=0A=
> implementation on other architectures: The layout is not taken from the=
=0A=
> production system and saved for the kdump kernel. Instead the kdump=0A=
> kernel needs to gather information about the whole memory without=0A=
> respect to locked out areas (like mem=3D and OLDMEM etc.).=0A=
> =0A=
> Without kdump's requirement it would of course be suitable and easy=0A=
> just to remove memory from memblock.memory. But then this information=0A=
> is lost for later use by kdump.=0A=
> =0A=
> The patch does not change any behaviour of the current API - whether it=
=0A=
> is enabled or not.=0A=
=0A=
Sorry, for the delayed reply.=0A=
=0A=
My main concern here was that you are introducing new *generic* API,=0A=
but in fact it is not generic, because it can't be re-used without huge rew=
ork=0A=
of existing code.=0A=
(at least as of wide usage of for_each_memblock(memory,...),=0A=
because (if ARCH_MEMBLOCK_NOMAP=3Dy) the meaning of "memory"=0A=
ranges will be changed form "mapped memory" to "real phys memory").=0A=
=0A=
And therefore, I've proposed to keep things as is and introduce phys_memory=
=0A=
ranges instead, to store real phys memory configuration.=0A=
=0A=
> =0A=
> The current patch seems to be overly complicated.=0A=
> The following patch contains only the nomap functionality without any=0A=
> cleanup and refactoring. I will post a V4 patch set which will contain=0A=
> this patch.=0A=
=0A=
Regards,=0A=
-grygorii=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
