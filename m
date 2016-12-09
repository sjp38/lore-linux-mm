Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E253C6B0261
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 11:49:49 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so47710275pgq.7
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 08:49:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z4si34574881pgo.126.2016.12.09.08.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 08:49:48 -0800 (PST)
Subject: Re: [RFC, PATCHv1 00/28] 5-level paging
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161209050130.GC2595@gmail.com> <20161209103722.GE30380@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0117384c-e591-2a91-3eab-1af0b0c9f9c9@intel.com>
Date: Fri, 9 Dec 2016 08:49:47 -0800
MIME-Version: 1.0
In-Reply-To: <20161209103722.GE30380@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/09/2016 02:37 AM, Kirill A. Shutemov wrote:
> On other hand, large virtual address space would put more pressure on
> cache -- at least one more page table per process, if we make 56-bit VA
> default.

For a process only using a small amount of its address space, the
mid-level paging structure caches will be very effective since the page
walks are all very similar.  You may take a cache miss on the extra
level on the *first* walk, but you only do that once per context switch.
 I bet the CPU is also pretty aggressive about filling those things when
it sees a new CR3 and they've been forcibly emptied.  So, you may never
even _see_ the latency from that extra miss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
