Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5011D6B0299
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:29:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x132-v6so7668114oif.21
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:29:09 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p41-v6si703176oth.68.2018.06.26.10.29.08
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 10:29:08 -0700 (PDT)
Date: Tue, 26 Jun 2018 18:29:01 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v4 0/7] arm64: untag user pointers passed to the kernel
Message-ID: <20180626172900.ufclp2pfrhwkxjco@armageddon.cambridge.arm.com>
References: <cover.1529507994.git.andreyknvl@google.com>
 <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

Hi Andrey,

On Tue, Jun 26, 2018 at 02:47:50PM +0200, Andrey Konovalov wrote:
> On Wed, Jun 20, 2018 at 5:24 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > arm64 has a feature called Top Byte Ignore, which allows to embed pointer
> > tags into the top byte of each pointer. Userspace programs (such as
> > HWASan, a memory debugging tool [1]) might use this feature and pass
> > tagged user pointers to the kernel through syscalls or other interfaces.
> >
> > This patch makes a few of the kernel interfaces accept tagged user
> > pointers. The kernel is already able to handle user faults with tagged
> > pointers and has the untagged_addr macro, which this patchset reuses.
> >
> > We're not trying to cover all possible ways the kernel accepts user
> > pointers in one patchset, so this one should be considered as a start.
> >
> > Thanks!
> >
> > [1] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html
> 
> Is there anything I should do to move forward with this?
> 
> I've received zero replies to this patch set (v3 and v4) over the last
> month.

The patches in this series look fine but my concern is that they are not
sufficient and we don't have (yet?) a way to identify where such
annotations are required. You even say in patch 6 that this is "some
initial work for supporting non-zero address tags passed to the kernel".
Unfortunately, merging (or relaxing) an ABI without a clear picture is
not really feasible.

While I support this work, as a maintainer I'd like to understand
whether we'd be in a continuous chase of ABI breaks with every kernel
release or we have a better way to identify potential issues. Is there
any way to statically analyse conversions from __user ptr to long for
example? Or, could we get the compiler to do this for us?

Thanks.

-- 
Catalin
