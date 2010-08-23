Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1961F6007EE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 13:53:09 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o7NHr3gr025718
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 10:53:03 -0700
Received: from gyd10 (gyd10.prod.google.com [10.243.49.202])
	by wpaz24.hot.corp.google.com with ESMTP id o7NHqhGA010803
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 10:53:02 -0700
Received: by gyd10 with SMTP id 10so2779439gyd.1
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 10:53:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100821054808.GA29869@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-5-git-send-email-mrubin@google.com> <20100821054808.GA29869@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Mon, 23 Aug 2010 10:52:39 -0700
Message-ID: <AANLkTikS+DUfPz0E2SmCZTQBWL8h2zSsGM8--yqEaVgZ@mail.gmail.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 10:48 PM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Fri, Aug 20, 2010 at 05:31:29PM +0800, Michael Rubin wrote:
>> The kernel already exposes the user desired thresholds in /proc/sys/vm
>> with dirty_background_ratio and background_ratio. But the kernel may
>> alter the number requested without giving the user any indication that
>> is the case.
>>
>> Knowing the actual ratios the kernel is honoring can help app developers
>> understand how their buffered IO will be sent to the disk.
>>
>> =A0 =A0 =A0 $ grep threshold /proc/vmstat
>> =A0 =A0 =A0 nr_dirty_threshold 409111
>> =A0 =A0 =A0 nr_dirty_background_threshold 818223
>
> I realized that the dirty thresholds has already been exported here:
>
> $ grep Thresh =A0/debug/bdi/8:0/stats
> BdiDirtyThresh: =A0 =A0 381000 kB
> DirtyThresh: =A0 =A0 =A0 1719076 kB
> BackgroundThresh: =A0 859536 kB
>
> So why not use that interface directly?

LOL. I know about these counters. This goes back and forth a lot.
The reason we don't want to use this interface is several fold.

1) It's exporting the implementation of writeback. We are doing bdi
today but one day we may not.
2) We need a non debugfs version since there are many situations where
debugfs requires root to mount and non root users may want this data.
Mounting debugfs all the time is not always an option.
3) Full system counters are easier to handle the juggling of removable
storage where these numbers will appear and disappear due to being
dynamic.

The goal is to get a full view of the system writeback behaviour not a
"kinda got it-oops maybe not" view.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
