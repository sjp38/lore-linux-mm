Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8241C6B0024
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 17:07:39 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u129-v6so1131368lff.9
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 14:07:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r8sor1194879ljj.20.2018.03.28.14.07.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 14:07:38 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <20180327234904.GA27734@bombadil.infradead.org>
Date: Thu, 29 Mar 2018 00:07:35 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <B26CA69E-B804-4607-9697-853DFE24C616@gmail.com>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180323124806.GA5624@bombadil.infradead.org>
 <651E0DB6-4507-4DA1-AD46-9C26ED9792A8@gmail.com>
 <20180326084650.GC5652@dhcp22.suse.cz>
 <01A133F4-27DF-4AE2-80D6-B0368BF758CD@gmail.com>
 <20180327072432.GY5652@dhcp22.suse.cz>
 <0549F29C-12FC-4401-9E85-A430BC11DA78@gmail.com>
 <CAGXu5j+XXufprMaJ9GbHxD3mZ7iqUuu60-tTMC6wo2x1puYzMQ@mail.gmail.com>
 <20180327234904.GA27734@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Richard Henderson <rth@twiddle.net>, ink@jurassic.park.msu.ru, mattst88@gmail.com, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, nyc@holomorphy.com, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Hugh Dickins <hughd@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Steve Capper <steve.capper@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nick Piggin <npiggin@gmail.com>, Bhupesh Sharma <bhsharma@redhat.com>, Rik van Riel <riel@redhat.com>, nitin.m.gupta@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-parisc <linux-parisc@vger.kernel.org>, PowerPC <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-sh <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>


> On 28 Mar 2018, at 02:49, Matthew Wilcox <willy@infradead.org> wrote:
>=20
> On Tue, Mar 27, 2018 at 03:53:53PM -0700, Kees Cook wrote:
>> I agree: pushing this off to libc leaves a lot of things unprotected.
>> I think this should live in the kernel. The question I have is about
>> making it maintainable/readable/etc.
>>=20
>> The state-of-the-art for ASLR is moving to finer granularity (over
>> just base-address offset), so I'd really like to see this supported =
in
>> the kernel. We'll be getting there for other things in the future, =
and
>> I'd like to have a working production example for researchers to
>> study, etc.
>=20
> One thing we need is to limit the fragmentation of this approach.
> Even on 64-bit systems, we can easily get into a situation where there =
isn't
> space to map a contiguous terabyte.

As I wrote before, shift_random is introduced to be fragmentation limit. =
Even=20
without it, the main question here is =E2=80=98if we can=E2=80=99t =
allocate memory with N size=20
bytes, how many bytes we already allocated?=E2=80=99. =46rom these point =
of view I=20
already showed in previous version of patch that if application uses not =
so big=20
memory allocations, it will have enough memory to use. If it uses XX =
Gigabytes=20
or Terabytes memory, this application has all chances to be exploited =
with=20
fully randomization or without. Since it is much easier to find(or =
guess) any=20
usable pointer, etc. For the instance you have only 128 terabytes of =
memory for=20
user space, so probability to exploit this application is 1/128 what is =
not=20
secure at all. This is very rough estimate but I try to make things =
easier to=20
understand.

Best regards,
Ilya
