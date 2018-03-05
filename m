Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB896B0280
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:50:37 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a143so14014335qkg.4
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:50:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g60si6527675qtd.280.2018.03.05.02.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:50:36 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w25Anhvx018164
	for <linux-mm@kvack.org>; Mon, 5 Mar 2018 05:50:35 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gh3t49p0f-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Mar 2018 05:50:35 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 5 Mar 2018 10:50:32 -0000
Subject: Re: [PATCH v8 18/24] mm: Provide speculative fault infrastructure
References: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1518794738-4186-19-git-send-email-ldufour@linux.vnet.ibm.com>
 <5b16d6ce-6b62-e4ca-2d78-c25bb008e27e@oracle.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 5 Mar 2018 11:50:21 +0100
MIME-Version: 1.0
In-Reply-To: <5b16d6ce-6b62-e4ca-2d78-c25bb008e27e@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <1d6c1ea9-6488-5e25-68b7-6f4aa07d1945@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Jordan,

Thanks for reporting this.

On 26/02/2018 18:16, Daniel Jordan wrote:
> Hi Laurent,
> 
> This series doesn't build for me[*] when CONFIG_TRANSPARENT_HUGEPAGE is unset.
> 
> The problem seems to be that the BUILD_BUG() version of pmd_same is called in
> pte_map_lock:
> 
> On 02/16/2018 10:25 AM, Laurent Dufour wrote:
>> +static bool pte_map_lock(struct vm_fault *vmf)
>> +{
> ...snip...
>> +A A A  if (!pmd_same(pmdval, vmf->orig_pmd))
>> +A A A A A A A  goto out;
> 
> Since SPF can now call pmd_same without THP, maybe the way to fix it is just
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 2cfa3075d148..e130692db24a 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -375,7 +375,8 @@ static inline int pte_unused(pte_t pte)
> A #endif
> A 
> A #ifndef __HAVE_ARCH_PMD_SAME
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || \
> +A A A  defined(CONFIG_SPECULATIVE_PAGE_FAULT)
> A static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
> A {
> A A A A A A A  return pmd_val(pmd_a) == pmd_val(pmd_b);

We can't fix that this way because some architectures define their own
pmd_same() function (like ppc64), thus forcing the define here will be useless
since __HAVE_ARCH_PMD_SAME is set in that case.

The right way to fix that is to _not check_ for the PMD value in pte_spinlock()
when CONFIG_TRANSPARENT_HUGEPAGE is not set since there is no risk of
collapsing operation in our back if THP are disabled.

I'll fix that in the next version.

Laurent.

> ?
> 
> Daniel
> 
> 
> [*]A  The errors are:
> 
> In file included from /home/dmjordan/src/linux/include/linux/kernel.h:10:0,
> A A A A A A A A A A A A A A A A  from /home/dmjordan/src/linux/include/linux/list.h:9,
> A A A A A A A A A A A A A A A A  from /home/dmjordan/src/linux/include/linux/smp.h:12,
> A A A A A A A A A A A A A A A A  from /home/dmjordan/src/linux/include/linux/kernel_stat.h:5,
> A A A A A A A A A A A A A A A A  from /home/dmjordan/src/linux/mm/memory.c:41:
> In function a??pmd_same.isra.104a??,
> A A A  inlined from a??pte_map_locka?? at /home/dmjordan/src/linux/mm/memory.c:2380:7:
> /home/dmjordan/src/linux/include/linux/compiler.h:324:38: error: call to
> a??__compiletime_assert_391a?? declared with attribute error: BUILD_BUG failed
> A  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  ^
> /home/dmjordan/src/linux/include/linux/compiler.h:304:4: note: in definition of
> macro a??__compiletime_asserta??
> A A A  prefix ## suffix();A A A  \
> A A A  ^~~~~~
> /home/dmjordan/src/linux/include/linux/compiler.h:324:2: note: in expansion of
> macro a??_compiletime_asserta??
> A  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> A  ^~~~~~~~~~~~~~~~~~~
> /home/dmjordan/src/linux/include/linux/build_bug.h:45:37: note: in expansion of
> macro a??compiletime_asserta??
> A #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  ^~~~~~~~~~~~~~~~~~
> /home/dmjordan/src/linux/include/linux/build_bug.h:79:21: note: in expansion of
> macro a??BUILD_BUG_ON_MSGa??
> A #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
> A A A A A A A A A A A A A A A A A A A A  ^~~~~~~~~~~~~~~~
> /home/dmjordan/src/linux/include/asm-generic/pgtable.h:391:2: note: in
> expansion of macro a??BUILD_BUGa??
> A  BUILD_BUG();
> A  ^~~~~~~~~
> A  CCA A A A A  block/elevator.o
> A  CCA A A A A  crypto/crypto_wq.o
> In function a??pmd_same.isra.104a??,
> A A A  inlined from a??pte_spinlocka?? at /home/dmjordan/src/linux/mm/memory.c:2326:7,
> A A A  inlined from a??handle_pte_faulta?? at
> /home/dmjordan/src/linux/mm/memory.c:4181:7:
> /home/dmjordan/src/linux/include/linux/compiler.h:324:38: error: call to
> a??__compiletime_assert_391a?? declared with attribute error: BUILD_BUG failed
> A  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  ^
> /home/dmjordan/src/linux/include/linux/compiler.h:304:4: note: in definition of
> macro a??__compiletime_asserta??
> A A A  prefix ## suffix();A A A  \
> A A A  ^~~~~~
> /home/dmjordan/src/linux/include/linux/compiler.h:324:2: note: in expansion of
> macro a??_compiletime_asserta??
> A  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> A  ^~~~~~~~~~~~~~~~~~~
> /home/dmjordan/src/linux/include/linux/build_bug.h:45:37: note: in expansion of
> macro a??compiletime_asserta??
> A #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  ^~~~~~~~~~~~~~~~~~
> /home/dmjordan/src/linux/include/linux/build_bug.h:79:21: note: in expansion of
> macro a??BUILD_BUG_ON_MSGa??
> A #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
> A A A A A A A A A A A A A A A A A A A A  ^~~~~~~~~~~~~~~~
> /home/dmjordan/src/linux/include/asm-generic/pgtable.h:391:2: note: in
> expansion of macro a??BUILD_BUGa??
> A  BUILD_BUG();
> A  ^~~~~~~~~
> ...
> make[2]: *** [/home/dmjordan/src/linux/scripts/Makefile.build:316: mm/memory.o]
> Error 1
> make[1]: *** [/home/dmjordan/src/linux/Makefile:1047: mm] Error 2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
