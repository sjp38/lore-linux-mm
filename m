Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D86D86B025E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:03:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so199718565pfb.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 09:03:39 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id q9si18480553paz.202.2016.06.13.09.03.38
        for <linux-mm@kvack.org>;
        Mon, 13 Jun 2016 09:03:39 -0700 (PDT)
Subject: Re: [PATCH 2/9] mm: implement new pkey_mprotect() system call
References: <20160609000117.71AC7623@viggo.jf.intel.com>
 <20160609000120.A3DD5140@viggo.jf.intel.com>
 <alpine.DEB.2.11.1606111147000.5839@nanos>
From: Dave Hansen <dave@sr71.net>
Message-ID: <575ED958.5060209@sr71.net>
Date: Mon, 13 Jun 2016 09:03:36 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1606111147000.5839@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On 06/11/2016 02:47 AM, Thomas Gleixner wrote:
> On Wed, 8 Jun 2016, Dave Hansen wrote:
>> > Proposed semantics:
>> > 1. protection key 0 is special and represents the default,
>> >    unassigned protection key.  It is always allocated.
>> > 2. mprotect() never affects a mapping's pkey_mprotect()-assigned
>> >    protection key. A protection key of 0 (even if set explicitly)
>> >    represents an unassigned protection key.
>> >    2a. mprotect(PROT_EXEC) on a mapping with an assigned protection
>> >        key may or may not result in a mapping with execute-only
>> >        properties.  pkey_mprotect() plus pkey_set() on all threads
>> >        should be used to _guarantee_ execute-only semantics.
>> > 3. mprotect(PROT_EXEC) may result in an "execute-only" mapping. The
>> >    kernel will internally attempt to allocate and dedicate a
>> >    protection key for the purpose of execute-only mappings.  This
>> >    may not be possible in cases where there are no free protection
>> >    keys available.
> Shouldn't we just reserve a protection key for PROT_EXEC unconditionally?

Normal userspace does not do PROT_EXEC today.  So, today, we'd
effectively lose one of our keys by reserving it.  Of the folks I've
talked to who really want this feature, and *will* actually use it, one
of the most common complaints is that there are too few keys.

Folks who actively *want* true PROT_EXEC semantics can use the explicit
pkey interfaces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
