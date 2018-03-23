Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFEB06B005A
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 14:10:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id e17so8460656qtm.13
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:10:45 -0700 (PDT)
Received: from brightrain.aerifal.cx (216-12-86-13.cv.mvl.ntelos.net. [216.12.86.13])
        by mx.google.com with ESMTP id y65si6572685qke.357.2018.03.23.11.10.44
        for <linux-mm@kvack.org>;
        Fri, 23 Mar 2018 11:10:44 -0700 (PDT)
Date: Fri, 23 Mar 2018 14:00:24 -0400
From: Rich Felker <dalias@libc.org>
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
Message-ID: <20180323180024.GB1436@brightrain.aerifal.cx>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180323124806.GA5624@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323124806.GA5624@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ilya Smith <blackzert@gmail.com>, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, jhogan@kernel.org, ralf@linux-mips.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, mhocko@suse.com, hughd@google.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, akpm@linux-foundation.org, steve.capper@arm.com, punit.agrawal@arm.com, paul.burton@mips.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, keescook@chromium.org, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, jglisse@redhat.com, aarcange@redhat.com, oleg@redhat.com, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 23, 2018 at 05:48:06AM -0700, Matthew Wilcox wrote:
> On Thu, Mar 22, 2018 at 07:36:36PM +0300, Ilya Smith wrote:
> > Current implementation doesn't randomize address returned by mmap.
> > All the entropy ends with choosing mmap_base_addr at the process
> > creation. After that mmap build very predictable layout of address
> > space. It allows to bypass ASLR in many cases. This patch make
> > randomization of address on any mmap call.
> 
> Why should this be done in the kernel rather than libc?  libc is perfectly
> capable of specifying random numbers in the first argument of mmap.

Generally libc does not have a view of the current vm maps, and thus
in passing "random numbers", they would have to be uniform across the
whole vm space and thus non-uniform once the kernel rounds up to avoid
existing mappings. Also this would impose requirements that libc be
aware of the kernel's use of the virtual address space and what's
available to userspace -- for example, on 32-bit archs whether 2GB,
3GB, or full 4GB (for 32-bit-user-on-64-bit-kernel) is available, and
on 64-bit archs where fewer than the full 64 bits are actually valid
in addresses, what the actual usable pointer size is. There is
currently no clean way of conveying this information to userspace.

Rich
