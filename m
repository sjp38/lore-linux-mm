Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 51FDA6B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 10:20:28 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 13 Feb 2013 08:15:54 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 3F284C40003
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 08:15:35 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1DFFYI9268668
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 08:15:34 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1DFFRd5008748
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 08:15:27 -0700
Message-ID: <511BADEA.3070403@linux.vnet.ibm.com>
Date: Wed, 13 Feb 2013 07:14:50 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: OOM triggered with plenty of memory free
References: <20130213031056.GA32135@marvin.atrad.com.au> <alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com> <20130213042552.GC32135@marvin.atrad.com.au>
In-Reply-To: <20130213042552.GC32135@marvin.atrad.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Woithe <jwoithe@atrad.com.au>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On 02/12/2013 08:25 PM, Jonathan Woithe wrote:
>> > Better yet would be to try to upgrade these machines to a more recent 
>> > kernel to see if it is already fixed.  Are we allowed to upgrade or at 
>> > least enable kmemleak?
> Upgrading to a recent kernel would be a possibility if it was proven to fix
> the problem; doing it "just to check" will be impossible I fear, at least on
> the production systems.  Enabling KMEMLEAK on 2.6.35.x may be doable.
> 
> I will see whether I can gain access to a test system and if so, try a more
> recent kernel to see if it makes any difference.
> 
> I'll advise which of these options proves practical as soon as possible and
> report any findings which come out of them.

Are there any non-upstream bits in the kernel?  Any third-party drivers
or filesystems?

David's analysis looks spot-on.  The only other thing I'll add is that
it just looks weird that all three kmalloc() caches are so _even_:

>> kmalloc-128       1234556 1235168    128   32    1 : tunables    0    0    0 : slabdata  38599  38599      0
>> kmalloc-64        1238117 1238144     64   64    1 : tunables    0    0    0 : slabdata  19346  19346      0
>> kmalloc-32        1236600 1236608     32  128    1 : tunables    0    0    0 : slabdata   9661   9661      0

It's almost like something goes and does 3 allocations in series and
leaks them all.

There are also quite a few buffer_heads:

> buffer_head       496273 640794     56   73    1 : tunables    0    0    0 : slabdata   8778   8778      0

which seem out-of-whack for the small amount of memory being used for
I/O-related stuff.  That kinda points in the direction of I/O or
filesystems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
