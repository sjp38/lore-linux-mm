Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B66326B0006
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:48:09 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id b23so7666971oib.16
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 07:48:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i125sor3367540oia.90.2018.02.26.07.48.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 07:48:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180226100611.sgw2rucvv6yhzn5y@quack2.suse.cz>
References: <151943298533.29249.14597996053028346159.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151943300713.29249.545330864711927648.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180226100611.sgw2rucvv6yhzn5y@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 26 Feb 2018 07:48:07 -0800
Message-ID: <CAPcyv4jDNW=9dNPtmX2oiHhp9S7wr+w7DPONZsx-LnLhcLPesg@mail.gmail.com>
Subject: Re: [PATCH v3 3/6] xfs, dax: introduce IS_FSDAX()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm@lists.01.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, kbuild test robot <fengguang.wu@intel.com>

On Mon, Feb 26, 2018 at 2:06 AM, Jan Kara <jack@suse.cz> wrote:
> On Fri 23-02-18 16:43:27, Dan Williams wrote:
>> Given that S_DAX is non-zero in the FS_DAX=n + DEV_DAX=y case, another
>> mechanism besides the plain IS_DAX() check to compile out dead
>> filesystem-dax code paths. Without IS_FSDAX() xfs will fail at link time
>> with:
>>
>>     ERROR: "dax_finish_sync_fault" [fs/xfs/xfs.ko] undefined!
>>     ERROR: "dax_iomap_fault" [fs/xfs/xfs.ko] undefined!
>>     ERROR: "dax_iomap_rw" [fs/xfs/xfs.ko] undefined!
>>
>> This compile failure was previously hidden by the fact that S_DAX was
>> erroneously defined to '0' in the FS_DAX=n + DEV_DAX=y case.
>>
>> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
>> Cc: linux-xfs@vger.kernel.org
>> Cc: <stable@vger.kernel.org>
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> As much as I appreciate that relying on compiler to optimize out dead
> branches results in nicer looking code this is an example where it
> backfires. Also having IS_DAX() and IS_FSDAX() doing almost the same, just
> not exactly the same, is IMHO a recipe for confusion (e.g. a casual reader
> could think why does ext4 get away with using IS_DAX while XFS has to use
> IS_FSDAX?). So I'd just prefer to handle this as is usual in other kernel
> areas - define empty stubs for all exported functions when CONFIG_FS_DAX is
> not enabled. That way code can stay without ugly ifdefs and we don't have
> to bother with IS_FSDAX vs IS_DAX distinction in filesystem code. Thoughts?
>

I think my patch is incomplete either way, because the current
IS_DAX() usages handle more than just compiling out calls to fs/dax.c
symbols. I.e. even if there were stubs for all fs/dax.c call outs call
there are still local usages of the helper. Lets kill IS_DAX() and
only have IS_FSDAX() and IS_DEVDAX() with the S_ISCHR() check. Any
issues with that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
