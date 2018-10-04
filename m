Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6BA06B0269
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:41:12 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k10-v6so7453843qtb.8
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:41:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i15-v6si1525031qvk.86.2018.10.04.00.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:41:11 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
 <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
 <20181003135407.GI4714@dhcp22.suse.cz>
 <9fef1f7d-2d7c-03f1-00e3-5fa657eda019@redhat.com>
 <20181004062811.GC22173@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <060bd891-f88e-13e1-2bb3-26d96f6d28cb@redhat.com>
Date: Thu, 4 Oct 2018 09:40:56 +0200
MIME-Version: 1.0
In-Reply-To: <20181004062811.GC22173@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

On 04/10/2018 08:28, Michal Hocko wrote:
> On Wed 03-10-18 19:00:29, David Hildenbrand wrote:
> [...]
>> Let me rephrase: You state that user space has to make the decision and
>> that user should be able to set/reconfigure rules. That is perfectly fine.
>>
>> But then we should give user space access to sufficient information to
>> make a decision. This might be the type of memory as we learned (what
>> some part of this patch proposes), but maybe later more, e.g. to which
>> physical device memory belongs (e.g. to hotplug it all movable or all
>> normal) ...
> 
> I am pretty sure that user knows he/she wants to use ballooning in
> HyperV or Xen, or that the memory hotplug should be used as a "RAS"
> feature to allow add and remove DIMMs for reliability. Why shouldn't we
> have a package to deploy an appropriate set of udev rules for each of
> those usecases? I am pretty sure you need some other plumbing to enable
> them anyway (e.g. RAS would require to have movable_node kernel
> parameters, ballooning a kernel module etc.).
> 
> Really, one udev script to rule them all will simply never work.
> 

I am on your side. We will need multiple ones. But we need sane
defaults. And a default rule will always exist. And users will expect
that the defaults somewhat match their expectation unless they really
have some special use cases.

All I am saying is, again, that if user space is to make decisions, it
should get sufficient information to make sane decision. And in my point
of view, the type of memory allows us to make these decision and to
provide a "single udev script to rule them all" with sane defaults.

I at least think the distinction between "auto-online" and "standby" is
required (what Dave suggested).

The we can make a simple rule

if (auto-online memory) {
	if (virtual environment) {
		"online"
	} else {
		"online_movable"
	}
}
/* standby memory not onlined as default */

We are able to provide sane defaults.

-- 

Thanks,

David / dhildenb
