Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 54285828E5
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 15:55:25 -0500 (EST)
Received: by mail-yk0-f181.google.com with SMTP id u9so92300888ykd.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 12:55:25 -0800 (PST)
Received: from mail-yw0-x229.google.com (mail-yw0-x229.google.com. [2607:f8b0:4002:c05::229])
        by mx.google.com with ESMTPS id p74si6235982yba.63.2016.02.08.12.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 12:55:24 -0800 (PST)
Received: by mail-yw0-x229.google.com with SMTP id u200so33307144ywf.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 12:55:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160208201808.GK27429@dastard>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
	<1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
	<CAPcyv4jT=yAb2_yLfMGqV1SdbQwoWQj7joroeJGAJAcjsMY_oQ@mail.gmail.com>
	<20160207215047.GJ31407@dastard>
	<CAPcyv4jNmdm-ATTBaLLLzBT+RXJ0YrxxXLYZ=T7xUgEJ8PaSKw@mail.gmail.com>
	<20160208201808.GK27429@dastard>
Date: Mon, 8 Feb 2016 12:55:24 -0800
Message-ID: <CAPcyv4iHi17pv_VC=WgEP4_GgN9OvSr8xbw1bvbEFMiQ83GbWw@mail.gmail.com>
Subject: Re: [PATCH 2/2] dax: move writeback calls into the filesystems
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>, jmoyer <jmoyer@redhat.com>

On Mon, Feb 8, 2016 at 12:18 PM, Dave Chinner <david@fromorbit.com> wrote:
[..]
>> Setting aside the current block zeroing problem you seem to assuming
>> that DAX will always be faster and that may not be true at a media
>> level.  Waiting years for some applications to determine if DAX makes
>> sense for their use case seems completely reasonable.  In the meantime
>> the apps that are already making these changes want to know that a DAX
>> mapping request has not silently dropped backed to page cache.  They
>> also want to know if they successfully jumped through all the hoops to
>> get a larger than pte mapping.
>>
>> I agree it is useful to be able to force DAX on an unmodified
>> application to see what happens, and it follows that if those
>> applications want to run in that mode they will need functional
>> fsync()...
>>
>> I would feel better if we were talking about specific applications and
>> performance numbers to know if forcing DAX on application is a debug
>> facility or a production level capability.  You seem to have already
>> made that determination and I'm curious what I'm missing.
>
> I'm not setting any policy here at all.  This whole argument is
> based around the DAX mount option doing "global fs enable or
> silently turning it off" and the application not knowing about that.
>
> The whole point of having a persistent per-inode DAX flags is that
> it is a policy mechanism, not a policy.  The application can, if it
> is DAX aware, directly control whether DAX is used on a file or not.
> The application can even query and clear that persistent inode flag
> if it is configured not to (or cannot) use DAX.
>
> If the filesystem cannot support DAX, then we can error out attempts
> to set the DAX flag and then the app knows DAX is not available.
> i.e. the attempt to set policy failed. If the flag is set, then the
> inode will *always* use DAX - there is no "fall back to page cache"
> when DAX is enabled.
>
> If the applicaiton is not DAX aware, then the admin can control the
> DAX policy by manipulating these flags themselves, and hence control
> whether DAX is used by the application or not.
>
> If you think I'm dictating policy for DAX users and application,
> then you haven't understood anything I've previously said about why
> the DAX mount option needs to die before any of this is considered
> production ready. DAX is not an opaque "all or nothing" option. XFS
> will provide apps and admins with fine-grained, persistent,
> discoverable policy flags to allow admins and applications to set
> DAX policies however they see fit. This simply cannot be done if the
> only knob you have is a mount option that may or may not stick.

I agree the mount option needs to die, and I fully grok the reasoning.
  What I'm concerned with is that a system using fully-DAX-aware
applications is forced to incur the overhead of maintaining *sync
semantics, periodic sync(2) in particular,  even if it is not relying
on those semantics.

However, like I said in my other mail, we can solve that with
alternate interfaces to persistent memory if that becomes an issue and
not require that "disable *sync" capability to come through DAX.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
