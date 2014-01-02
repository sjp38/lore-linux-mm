Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 785F26B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 07:29:57 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id at1so14617660iec.33
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 04:29:57 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id l3si72576945igx.53.2014.01.02.04.29.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 04:29:55 -0800 (PST)
Message-ID: <1388665786.4373.48.camel@pasglop>
Subject: Re: [PATCH -V2] powerpc: thp: Fix crash on mremap
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 02 Jan 2014 23:29:46 +1100
In-Reply-To: <87zjneodtw.fsf@linux.vnet.ibm.com>
References: 
	<1388654266-5195-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20140102094124.04D76E0090@blue.fi.intel.com>
	 <87zjneodtw.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, paulus@samba.org, aarcange@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 2014-01-02 at 16:22 +0530, Aneesh Kumar K.V wrote:
> > Just use config option directly:
> >
> >       if (new_ptl != old_ptl ||
> >               IS_ENABLED(CONFIG_ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW))
> 
> 
> I didn't like that. I found the earlier one easier for reading.
> If you and others strongly feel about this, I can redo the patch.
> Please let me know

Yes, use IS_ENABLED, no need to have two indirections of #define's

Another option is to have

	if (pmd_move_must_withdraw(new,old)) {
	}

With in a generic header:

#ifndef pmd_move_must_withdraw
static inline bool pmd_move_must_withdraw(spinlock_t *new_ptl, ...)
{
	return new_ptl != old_ptl;
}
#endif

And in powerpc:

static inline bool pmd_move_must_withdraw(spinlock_t *new_ptl, ...)
{
	return true;
}
#define pmd_move_must_withdraw pmd_move_must_withdraw

Cheers,
Ben.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
