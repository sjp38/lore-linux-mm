Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A64826B0038
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 22:18:02 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s185so2934189oif.3
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 19:18:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n51sor4683897otb.119.2017.10.11.19.17.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 19:18:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jr4atxCqFW_337Sguu8LswVgjsJVOd65n4RODttX9cxQ@mail.gmail.com>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150776923838.9144.15727770472447035032.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171012012131.GD21978@ZenIV.linux.org.uk> <CAPcyv4jr4atxCqFW_337Sguu8LswVgjsJVOd65n4RODttX9cxQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 11 Oct 2017 19:17:58 -0700
Message-ID: <CAPcyv4ij9E9tXPLqp6cUAY3dJzh7OS+yPsVDME50xSvQPLpStA@mail.gmail.com>
Subject: Re: [PATCH v9 2/6] fs, mm: pass fd to ->mmap_validate()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Oct 11, 2017 at 6:28 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Wed, Oct 11, 2017 at 6:21 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> On Wed, Oct 11, 2017 at 05:47:18PM -0700, Dan Williams wrote:
>>> The MAP_DIRECT mechanism for mmap intends to use a file lease to prevent
>>> block map changes while the file is mapped. It requires the fd to setup
>>> an fasync_struct for signalling lease break events to the lease holder.
>>
>> *UGH*
>>
>> That looks like one hell of a bad API.  You are not even guaranteed that
>> descriptor will remain be still open by the time you pass it down to your
>> helper, nevermind the moment when event actually happens...
>
> What am I missing, fcntl(F_SETLEASE) seems to follow a similar pattern?

Ugh, so I think the difference with F_SETLEASE is that the lease ends
when the fd is closed. In the mmap case the lease follows the lifetime
of the vma. I'll rethink this interface...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
