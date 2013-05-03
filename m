Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 2C0956B02EF
	for <linux-mm@kvack.org>; Fri,  3 May 2013 14:54:53 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 4 May 2013 00:20:10 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 35AA4125804E
	for <linux-mm@kvack.org>; Sat,  4 May 2013 00:26:30 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43Isdp03473804
	for <linux-mm@kvack.org>; Sat, 4 May 2013 00:24:40 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43IsjWi027901
	for <linux-mm@kvack.org>; Sat, 4 May 2013 04:54:46 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 02/10] powerpc/THP: Implement transparent hugepages for ppc64
In-Reply-To: <20130503115428.GW13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367178711-8232-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130503045201.GO13041@truffula.fritz.box> <1367569143.4389.56.camel@pasglop> <20130503115428.GW13041@truffula.fritz.box>
Date: Sat, 04 May 2013 00:24:45 +0530
Message-ID: <87li7v51xm.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, paulus@samba.org

David Gibson <dwg@au1.ibm.com> writes:

> On Fri, May 03, 2013 at 06:19:03PM +1000, Benjamin Herrenschmidt wrote:
>> On Fri, 2013-05-03 at 14:52 +1000, David Gibson wrote:
>> > Here, specifically, the fact that PAGE_BUSY is in PAGE_THP_HPTEFLAGS
>> > is likely to be bad.  If the page is busy, it's in the middle of
>> > update so can't stably be considered the same as anything.
>> 
>> _PAGE_BUSY is more like a read lock. It means it's being hashed, so what
>> is not stable is _PAGE_HASHPTE, slot index, _ACCESSED and _DIRTY. The
>> rest is stable and usually is what pmd_same looks at (though I have a
>> small doubt vs. _ACCESSED and _DIRTY but at least x86 doesn't care since
>> they are updated by HW).
>
> Ok.  It still seems very odd to me that _PAGE_BUSY would be in the THP
> version of _PAGE_HASHPTE, but not the normal one.
>

64-4k definition:
/* PTE flags to conserve for HPTE identification */
#define _PAGE_HPTEFLAGS (_PAGE_BUSY | _PAGE_HASHPTE | \
			 _PAGE_SECONDARY | _PAGE_GROUP_IX)

64-64K definition:
/* PTE flags to conserve for HPTE identification */
#define _PAGE_HPTEFLAGS (_PAGE_BUSY | _PAGE_HASHPTE | _PAGE_COMBO)

BTW I have dropped that change in my current patch. I dropped the
usage of _PAGE_COMBO and instead started using _PAGE_4K_PFN for
identifying THP.That enabled me to use _PAGE_HPTEFLAGS as it is.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
