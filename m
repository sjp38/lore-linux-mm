Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 562426B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 23:22:08 -0400 (EDT)
Message-ID: <4FFE42B6.5080705@oracle.com>
Date: Thu, 12 Jul 2012 11:21:26 +0800
From: Jeff Liu <jeff.liu@oracle.com>
Reply-To: jeff.liu@oracle.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] tmpfs: revert SEEK_DATA and SEEK_HOLE
References: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils> <alpine.LSU.2.00.1207091535480.2051@eggly.anvils> <jtj574$tb7$2@dough.gmane.org> <alpine.LSU.2.00.1207111149580.1797@eggly.anvils> <20120711230122.GZ19223@dastard>
In-Reply-To: <20120711230122.GZ19223@dastard>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Hugh Dickins <hughd@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/12/2012 07:01 AM, Dave Chinner wrote:

> On Wed, Jul 11, 2012 at 11:55:34AM -0700, Hugh Dickins wrote:
>> On Wed, 11 Jul 2012, Cong Wang wrote:
>>> On Mon, 09 Jul 2012 at 22:41 GMT, Hugh Dickins <hughd@google.com> wrote:
>>>> Revert 4fb5ef089b28 ("tmpfs: support SEEK_DATA and SEEK_HOLE").
>>>> I believe it's correct, and it's been nice to have from rc1 to rc6;
>>>> but as the original commit said:
>>>>
>>>> I don't know who actually uses SEEK_DATA or SEEK_HOLE, and whether it
>>>> would be of any use to them on tmpfs.  This code adds 92 lines and 752
>>>> bytes on x86_64 - is that bloat or worthwhile?
>>>
>>>
>>> I don't think 752 bytes matter much, especially for x86_64.
>>>
>>>>
>>>> Nobody asked for it, so I conclude that it's bloat: let's revert tmpfs
>>>> to the dumb generic support for v3.5.  We can always reinstate it later
>>>> if useful, and anyone needing it in a hurry can just get it out of git.
>>>>
>>>
>>> If you don't have burden to maintain it, I'd prefer to leave as it is,
>>> I don't think 752-bytes is the reason we revert it.
>>
>> Thank you, your vote has been counted ;)
>> and I'll be glad if yours stimulates some agreement or disagreement.
>>
>> But your vote would count for a lot more if you know of some app which
>> would really benefit from this functionality in tmpfs: I've heard of none.
> 
> So what? I've heard of no apps that use this functionality on XFS,
> either, but I have heard of a lot of people asking for it to be
> implemented over the past couple of years so they can use it.
> There's been patches written to make coreutils (cp) make use of it
> instead of parsing FIEMAP output to find holes, though I don't know
> if that's gone beyond more than "here's some patches"...

Yes, for apps, cp(1) will make use of it to replace the old FIEMAP for efficient sparse file copy.
I have implemented an extent-scan module to coreutils a few years ago,
http://fossies.org/dox/coreutils-8.17/extent-scan_8c_source.html

It does extent scan through FIEMAP, however, SEEK_DATA/SEEK_HOLE is more convenient and easy to use
considering the call interface.  So FIEMAP will be replaced by SEEK_XXX once it got supported by EXT4.

Moreover, I have discussed with Jim who is the coreutils maintainer previously, He would like to post
extent-scan module to Gnulib so that other GNU utilities which are relied on Gnulib might be a potential
user of it, at least, GNU tar will definitely need it for sparse file backup.

> 
> Besides, given that you can punch holes in tmpfs files, it seems
> strange to then say "we don't need a method of skipping holes to
> find data quickly"....

So its deserve to keep this feature working on tmpfs considering hole punch. :)

Thanks,
-Jeff

> 
> Besides, seek-hole/data is still shiny new and lots of developers
> aren't even aware of it's presence in recent kernels. Removing new
> functionality saying "no-one is using it" is like smashing the egg
> before the chicken hatches (or is it cutting of the chickes's head
> before it lays the egg?).
> 
> Cheers,
> 
> Dave.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
