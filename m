Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 799756B0266
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 11:44:03 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 91so19462359otr.18
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 08:44:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17-v6sor10064285oie.69.2018.10.17.08.44.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 08:44:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181017120829.GA19731@infradead.org>
References: <20181009222042.9781-1-joel@joelfernandes.org> <20181017095155.GA354@infradead.org>
 <20181017103958.GB230639@joelaf.mtv.corp.google.com> <20181017120829.GA19731@infradead.org>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 17 Oct 2018 08:44:01 -0700
Message-ID: <CAKOZuesr_8vrob-XfEpGmyeKFEhWWXZo4BEC0PixfjT2ibaRZQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: Add an F_SEAL_FS_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@android.com, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@google.com>, Shuah Khan <shuah@kernel.org>

On Wed, Oct 17, 2018 at 5:08 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Oct 17, 2018 at 03:39:58AM -0700, Joel Fernandes wrote:
>> > > This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
>> > > To support the usecase, this patch adds a new F_SEAL_FS_WRITE seal which
>> > > prevents any future mmap and write syscalls from succeeding while
>> > > keeping the existing mmap active. The following program shows the seal
>> > > working in action:
>> >
>> > Where does the FS come from?  I'd rather expect this to be implemented
>> > as a 'force' style flag that applies the seal even if the otherwise
>> > required precondition is not met.
>>
>> The "FS" was meant to convey that the seal is preventing writes at the VFS
>> layer itself, for example vfs_write checks FMODE_WRITE and does not proceed,
>> it instead returns an error if the flag is not set. I could not find a better
>> name for it, I could call it F_SEAL_VFS_WRITE if you prefer?
>
> I don't think there is anything VFS or FS about that - at best that
> is an implementation detail.
>
> Either do something like the force flag I suggested in the last mail,
> or give it a name that matches the intention, e.g F_SEAL_FUTURE_WRITE.

+1

>> > This seems to lack any synchronization for f_mode.
>>
>> The f_mode is set when the struct file is first created and then memfd sets
>> additional flags in memfd_create. Then later we are changing it here at the
>> time of setting the seal. I donot see any possiblity of a race since it is
>> impossible to set the seal before memfd_create returns. Could you provide
>> more details about what kind of synchronization is needed and what is the
>> race condition scenario you were thinking off?
>
> Even if no one changes these specific flags we still need a lock due
> to rmw cycles on the field.  For example fadvise can set or clear
> FMODE_RANDOM.  It seems to use file->f_lock for synchronization.

Compare-and-exchange will suffice, right?
