Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 306756B02FC
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 13:29:00 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y11so30907wmd.5
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 10:29:00 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id j1si451879wrc.494.2018.02.22.10.28.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 10:28:58 -0800 (PST)
Subject: Re: [PATCH 2/6] genalloc: selftest
From: Igor Stoppa <igor.stoppa@huawei.com>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <20180212165301.17933-3-igor.stoppa@huawei.com>
 <CAGXu5jJNERp-yni1jdqJRYJ82xrP7=_O1vkxG1sJ-b8CxudP9g@mail.gmail.com>
 <f33112e4-608f-ae8c-bf88-80ef83b61398@huawei.com>
 <CAGXu5jLeC285BGDW29aHgFZRV6CnqBmmkZULW2pzYmqd0pe9UQ@mail.gmail.com>
 <fb001cd0-7f37-394f-f926-f5b98365b4b8@huawei.com>
Message-ID: <81471cf6-5a27-6e8c-ac7c-e7c4cc35d410@huawei.com>
Date: Thu, 22 Feb 2018 20:28:30 +0200
MIME-Version: 1.0
In-Reply-To: <fb001cd0-7f37-394f-f926-f5b98365b4b8@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph
 Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 22/02/18 11:14, Igor Stoppa wrote:
> 
> 
> On 22/02/18 00:28, Kees Cook wrote:
>> On Tue, Feb 20, 2018 at 8:59 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>>>
>>>
>>> On 13/02/18 01:50, Kees Cook wrote:
>>>> On Mon, Feb 12, 2018 at 8:52 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> 
> [...]
> 
>>>>> +       genalloc_selftest();
>>>>
>>>> I wonder if it's possible to make this module-loadable instead? That
>>>> way it could be built and tested separately.
>>>
>>> In my case modules are not an option.
>>> Of course it could be still built in, but what is the real gain?
>>
>> The gain for it being a module is that it can be loaded and tested
>> separately from the final kernel image and module collection. For
>> example, Chrome OS builds lots of debugging test modules but doesn't
>> include them on the final image. They're only used for testing, and
>> can be separate from the kernel and "production" modules.
> 
> ok

I started to turn this into a module, but after all it doesn't seem like
it would give any real advantage, compared to the current implementation.

This testing is meant to catch bugs in memory management as early as
possible in the boot phase, before users of genalloc start to fail in
mysterious ways.

This includes, but is not limited to: MCE on x86, uncached pages
provider on arm64, dma on arm.

Should genalloc fail, it's highly unlikely that the test rig would even
reach the point where it can load a module and run it, even if it is
located in initrd.

The test would not be run, precisely at the moment where its output
would be needed the most, leaving a crash log that is hard to debug
because of memory corruption.

I do not know how Chrome OS builds are organized, but I imagine that
probably there is a separate test build, where options like lockdep,
ubsan, etc. are enabled.

All options that cannot be left enabled in a production kernel, but are
very useful for sanity checks and require a separate build.

Genalloc testing should be added there, rather than in a module, imho.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
