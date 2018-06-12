Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE88B6B000C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 11:23:49 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id m1-v6so3188462uao.13
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 08:23:49 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 81-v6si197973uau.251.2018.06.12.08.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 08:23:48 -0700 (PDT)
Date: Tue, 12 Jun 2018 08:23:42 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [mmotm:master] BUILD REGRESSION
 7393732bae530daa27567988b91d16ecfeef6c62
Message-ID: <20180612152342.gai2obwfk6xz2t2e@ca-dmjordan1.us.oracle.com>
References: <5b1a87b7.7PNFYCcgPGh68IFP%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b1a87b7.7PNFYCcgPGh68IFP%lkp@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jun 08, 2018 at 09:42:15PM +0800, kbuild test robot wrote:
> tree/branch: git://git.cmpxchg.org/linux-mmotm.git  master
> branch HEAD: 7393732bae530daa27567988b91d16ecfeef6c62  pci: test for unexpectedly disabled bridges
> 
> Regressions in current branch:
> 
> drivers/scsi//qedf/qedf_main.c:3569:6: error: redefinition of 'qedf_get_protocol_tlv_data'
> drivers/scsi/qedf/qedf_main.c:3569:6: error: redefinition of 'qedf_get_protocol_tlv_data'
> drivers/scsi//qedf/qedf_main.c:3649:6: error: redefinition of 'qedf_get_generic_tlv_data'
> drivers/scsi/qedf/qedf_main.c:3649:6: error: redefinition of 'qedf_get_generic_tlv_data'
> drivers/thermal/qcom/tsens.c:144:31: error: 's' undeclared (first use in this function)
> fs/dax.c:1031:2: error: 'entry2' undeclared (first use in this function)
> fs/dax.c:1031:2: error: 'entry2' undeclared (first use in this function); did you mean 'entry'?
> fs/fat/inode.c:162:25: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t {aka long long unsigned int}' [-Wformat=]
> fs/fat/inode.c:162:3: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t' [-Wformat=]
> fs///fat/inode.c:163:9: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t {aka long long unsigned int}' [-Wformat=]
> fs/fat/inode.c:163:9: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t {aka long long unsigned int}' [-Wformat=]
> include/asm-generic/int-ll64.h:16:9: error: unknown type name '__s8'
> include/net/ipv6.h:299:2: error: unknown type name '__s8'
> include/uapi/asm-generic/int-ll64.h:20:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'typedef'
> include/uapi/linux/dqblk_xfs.h:54:2: error: unknown type name '__s8'
> include/uapi/linux/ethtool.h:1834:2: error: unknown type name '__s8'
> include/uapi/linux/if_bonding.h:107:2: error: unknown type name '__s8'

> net/ipv4/ipconfig.c:1:2: error: expected ';' before 'typedef'

Hit this today.  A wayward 'q' snuck into linux-next-git-rejects.patch:

  diff -puN net/ipv4/ipconfig.c~linux-next-git-rejects net/ipv4/ipconfig.c
  --- a/net/ipv4/ipconfig.c~linux-next-git-rejects
  +++ a/net/ipv4/ipconfig.c
  @@ -1,4 +1,4 @@
  -// SPDX-License-Identifier: GPL-2.0
  +q// SPDX-License-Identifier: GPL-2.0

Removing the q fixes all the errors above, but there's another build issue if
you don't have CONFIG_HYPERV=y:

  arch/x86/kvm/vmx.o: In function `alloc_loaded_vmcs':                                                                                                
  /storage/dmjordan/linux/arch/x86/kvm/vmx.c:4404: undefined reference to `ms_hyperv'

This one disappears with https://patchwork.kernel.org/patch/10427825/

v4.17-mmotm-2018-06-07-16-59 from linux-mmotm builds with both fixes.
