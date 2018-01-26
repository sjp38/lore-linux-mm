Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84E9A6B0068
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 02:55:26 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id j13so1533054wmh.3
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 23:55:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u186si3865918wmu.82.2018.01.26.23.55.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jan 2018 23:55:25 -0800 (PST)
Date: Fri, 26 Jan 2018 15:04:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
Message-ID: <20180126140415.GD5027@dhcp22.suse.cz>
References: <20180109161355.GL1732@dhcp22.suse.cz>
 <a495f210-0015-efb2-a6a7-868f30ac4ace@linux.vnet.ibm.com>
 <20180117080731.GA2900@dhcp22.suse.cz>
 <082aa008-c56a-681d-0949-107245603a97@linux.vnet.ibm.com>
 <20180123124545.GL1526@dhcp22.suse.cz>
 <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
 <20180123160653.GU1526@dhcp22.suse.cz>
 <2a05eaf2-20fd-57a8-d4bd-5a1fbf57686c@linux.vnet.ibm.com>
 <20180124090539.GH1526@dhcp22.suse.cz>
 <5acba3c2-754d-e449-24ff-a72a0ad0d895@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5acba3c2-754d-e449-24ff-a72a0ad0d895@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Fri 26-01-18 18:04:27, Anshuman Khandual wrote:
[...]
> I tried to instrument mmap_region() for a single instance of 'sed'
> binary and traced all it's VMA creation. But there is no trace when
> that 'anon' VMA got created which suddenly shows up during subsequent
> elf_map() call eventually failing it. Please note that the following
> VMA was never created through call into map_region() in the process
> which is strange.

Could you share your debugging patch?

> =================================================================
> [    9.076867] Details for VMA[3] c000001fce42b7c0
> [    9.076925] vma c000001fce42b7c0 start 0000000010030000 end 0000000010040000
> next c000001fce42b580 prev c000001fce42b880 mm c000001fce40fa00
> prot 8000000000000104 anon_vma           (null) vm_ops           (null)
> pgoff 1003 file           (null) private_data           (null)
> flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
> =================================================================

Isn't this vdso or some other special mapping? It is not really an
anonymous vma. Please hook into __install_special_mapping

> VMA creation for 'sed' binary
> =============================
> [    9.071902] XXX: mm c000001fce40fa00 registered
> 
> [    9.071971] Total VMAs 2 on MM c000001fce40fa00
> ----
> [    9.072010] Details for VMA[1] c000001fce42bdc0
> [    9.072064] vma c000001fce42bdc0 start 0000000010000000 end 0000000010020000
> next c000001fce42b580 prev           (null) mm c000001fce40fa00
> prot 8000000000000105 anon_vma           (null) vm_ops c008000011ddca18
> pgoff 0 file c000001fe2969a00 private_data           (null)
> flags: 0x875(read|exec|mayread|maywrite|mayexec|denywrite)

This one doesn't have any stack trace either... Yet it is a file
mapping obviously. Special mappings shouldn't have any file associated.
Strange...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
