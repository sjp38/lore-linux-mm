Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0B8E6B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 08:10:44 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id ce7-v6so1713115plb.22
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 05:10:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8-v6si1120539pgn.554.2018.10.02.05.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 05:10:43 -0700 (PDT)
Date: Tue, 2 Oct 2018 14:10:39 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002121039.GA3274@linux-x5ow.site>
References: <20181002100531.GC4135@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181002100531.GC4135@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Oct 02, 2018 at 12:05:31PM +0200, Jan Kara wrote:
> Hello,
> 
> commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
> removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
> mean time certain customer of ours started poking into /proc/<pid>/smaps
> and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
> flags, the application just fails to start complaining that DAX support is
> missing in the kernel. The question now is how do we go about this?

OK naive question from me, how do we want an application to be able to
check if it is running on a DAX mapping?

AFAIU DAX is always associated with a file descriptor of some kind (be
it a real file with filesystem dax or the /dev/dax device file for
device dax). So could a new fcntl() be of any help here? IS_DAX() only
checks for the S_DAX flag in inode::i_flags, so this should be doable
for both fsdax and devdax.

I haven't tried it yet but it should be fairly easy to come up with
something like this.

Byte,
	Johannes
-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
