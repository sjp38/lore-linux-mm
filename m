Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78F3C6B0038
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 10:33:02 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q46so21881736qtb.16
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 07:33:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g31si4966336qtd.131.2017.04.07.07.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 07:33:01 -0700 (PDT)
Date: Fri, 7 Apr 2017 10:32:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 01/16] mm/memory/hotplug: add memory type parameter to
 arch_add/remove_memory
Message-ID: <20170407143246.GA15098@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-2-jglisse@redhat.com>
 <20170407121349.GB16392@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170407121349.GB16392@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Fri, Apr 07, 2017 at 02:13:49PM +0200, Michal Hocko wrote:
> On Wed 05-04-17 16:40:11, Jerome Glisse wrote:
> > When hotpluging memory we want more information on the type of memory.
> > This is to extend ZONE_DEVICE to support new type of memory other than
> > the persistent memory. Existing user of ZONE_DEVICE (persistent memory)
> > will be left un-modified.
> 
> My current hotplug rework [1] is touching this path as well. It is not
> really clear from the chage why you are changing this and what are the
> further expectations of MEMORY_DEVICE_PERSISTENT. Infact I have replaced
> for_device with want__memblock [2]. I plan to repost shortly but I would
> like to understand your modifications more to reduce potential conflicts
> in the code. Why do you need to distinguish different types of memory
> anyway.
> 
> [1] http://lkml.kernel.org/r/20170330115454.32154-1-mhocko@kernel.org
> [2] the current patchset is in git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
>     branch attempts/rewrite-mem_hotplug-WIP

This is needed for UNADDRESSABLE memory type introduced in patch 3 and
the arch specific bits are in patch 4. Basicly for UNADDRESSABLE memory
i do not want the arch code to create a linear mapping for the range
being hotpluged. Adding memory_type in this patch allow to distinguish
between different type of ZONE_DEVICE.

After your patchset, we do not need the for_device but i still need to
know if it is UNADDRESSABLE. You can check my branch on top of your
previous patchset (again patch 1, 3 and 4):

https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v20

1:
https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v20&id=a85a895615e4812d3c68869cfeef92a4924b4946
3:
https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v20&id=539b6d12429a7166f3690944d6bf164930a59def
4:
https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v20&id=d5338b868e801acabb96c7166c1e802d730511e3

I will check your new branch and see what want_memblock is for.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
