Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5867D6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 11:37:22 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id v14so227835479ykd.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 08:37:22 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id x143si6843129ywx.233.2016.01.06.08.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 08:37:21 -0800 (PST)
Received: by mail-yk0-x22f.google.com with SMTP id x67so321180423ykd.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 08:37:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iijhdXnD-4PuHkzbhhPra8eCRZ=df3XTE=z-efbQmVww@mail.gmail.com>
References: <cover.1451952351.git.tony.luck@intel.com>
	<5b0243c5df825ad0841f4bb5584cd15d3f013f09.1451952351.git.tony.luck@intel.com>
	<CAPcyv4jjWT3Od_XvGpVb+O7MT95mBRXviPXi1zUfM5o+kN4CUA@mail.gmail.com>
	<A527EC4B-4069-4FDE-BE4C-5279C45BCABE@intel.com>
	<CAPcyv4iijhdXnD-4PuHkzbhhPra8eCRZ=df3XTE=z-efbQmVww@mail.gmail.com>
Date: Wed, 6 Jan 2016 08:37:21 -0800
Message-ID: <CAPcyv4g1dGC2YMN+JZPKhzbCm8PQJ7nJqV4JGjJ3w1PAf12v+Q@mail.gmail.com>
Subject: Re: [PATCH v7 3/3] x86, mce: Add __mcsafe_copy()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Tue, Jan 5, 2016 at 11:11 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Tue, Jan 5, 2016 at 11:06 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> You were heading towards:
>>
>> ld: undefined __mcsafe_copy
>
> True, we'd also need a dummy mcsafe_copy() definition to compile it
> out in the disabled case.
>
>> since that is also inside the #ifdef.
>>
>> Weren't you going to "select" this?
>>
>
> I do select it, but by randconfig I still need to handle the
> CONFIG_X86_MCE=n case.
>
>> I'm seriously wondering whether the ifdef still makes sense. Now I don't have an extra exception table and routines to sort/search/fixup, it doesn't seem as useful as it was a few iterations ago.
>
> Either way is ok with me.  That said, the extra definitions to allow
> it compile out when not enabled don't seem too onerous.

This works for me, because all we need is the definitions.  As long as
we don't attempt to link to mcsafe_copy() we get the benefit of
compiling this out when de-selected:


diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
index 16a8f0e56e4a..5b24039463a4 100644
--- a/arch/x86/include/asm/string_64.h
+++ b/arch/x86/include/asm/string_64.h
@@ -78,7 +78,6 @@ int strcmp(const char *cs, const char *ct);
#define memset(s, c, n) __memset(s, c, n)
#endif

-#ifdef CONFIG_MCE_KERNEL_RECOVERY
struct mcsafe_ret {
       u64 trapnr;
       u64 remain;
@@ -86,7 +85,6 @@ struct mcsafe_ret {

struct mcsafe_ret __mcsafe_copy(void *dst, const void __user *src, size_t cnt);
extern void __mcsafe_copy_end(void);
-#endif

#endif /* __KERNEL__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
