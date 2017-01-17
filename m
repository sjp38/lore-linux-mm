Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 646E96B0266
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:56:54 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 65so43644362otq.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:56:54 -0800 (PST)
Received: from mail-ot0-x22b.google.com (mail-ot0-x22b.google.com. [2607:f8b0:4003:c0f::22b])
        by mx.google.com with ESMTPS id 34si5907165otf.6.2017.01.17.08.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 08:56:53 -0800 (PST)
Received: by mail-ot0-x22b.google.com with SMTP id 73so66725677otj.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:56:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170117155910.GU2517@quack2.suse.cz>
References: <20170114002008.GA25379@linux.intel.com> <20170117155910.GU2517@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 17 Jan 2017 08:56:52 -0800
Message-ID: <CAPcyv4hO5ZjrBk=L1DLkf4SP5fFeTAD+o7GUQDv0fcJj4Q+pCg@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Future direction of DAX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>

On Tue, Jan 17, 2017 at 7:59 AM, Jan Kara <jack@suse.cz> wrote:
> On Fri 13-01-17 17:20:08, Ross Zwisler wrote:
>> - The DAX fsync/msync model was built for platforms that need to flush dirty
>>   processor cache lines in order to make data durable on NVDIMMs.  There exist
>>   platforms, however, that are set up so that the processor caches are
>>   effectively part of the ADR safe zone.  This means that dirty data can be
>>   assumed to be durable even in the processor cache, obviating the need to
>>   manually flush the cache during fsync/msync.  These platforms still need to
>>   call fsync/msync to ensure that filesystem metadata updates are properly
>>   written to media.  Our first idea on how to properly support these platforms
>>   would be for DAX to be made aware that in some cases doesn't need to keep
>>   metadata about dirty cache lines.  A similar issue exists for volatile uses
>>   of DAX such as with BRD or with PMEM and the memmap command line parameter,
>>   and we'd like a solution that covers them all.
>
> Well, we still need the radix tree entries for locking. And you still need
> to keep track of which file offsets are writeably mapped (which we
> currently implicitely keep via dirty radix tree entries) so that you can
> writeprotect them if needed (during filesystem freezing, for reflink, ...).
> So I think what is going to gain the most by far is simply to avoid doing
> the writeback at all in such situations.

I came to the same conclusion when taking a look at this. I have some
patches that simply make the writeback optional, but do not touch any
of the other dirty tracking infrastructure. I'll send them out shortly
after a bit more testing. This also dovetails with the request from
Linus to push pmem flushing routines into the driver and stop abusing
__copy_user_nocache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
