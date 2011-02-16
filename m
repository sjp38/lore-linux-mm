Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A3E878D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 23:36:25 -0500 (EST)
Received: by iyi20 with SMTP id 20so833085iyi.14
        for <linux-mm@kvack.org>; Tue, 15 Feb 2011 20:36:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <e647042e-419e-4e61-a563-e489596bd659@default>
References: <20110207032407.GA27404@ca-server1.us.oracle.com>
	<1ddd01a8-591a-42bc-8bb3-561843b31acb@default>
	<AANLkTimFATx-gYVgY_pVdZsySSBmXvKFkhTJUeVFBcop@mail.gmail.com>
	<AANLkTimqSSxHrLhL9t4DOmDeuAA41B9e-qnr+vnUsucL@mail.gmail.com>
	<AANLkTi=4QkV4wtMmDd6+XXhvkva+fq9m5PVYGC0qBUc3@mail.gmail.com>
	<AANLkTimOssgM7JYSpwB=5zmF_JJ2ByH+PWO7N+YZNB_y@mail.gmail.com>
	<e647042e-419e-4e61-a563-e489596bd659@default>
Date: Wed, 16 Feb 2011 13:36:18 +0900
Message-ID: <AANLkTim_U+mJtHk7drvqMOmUwd4ro8J0dazZMDsNqH=o@mail.gmail.com>
Subject: Re: [PATCH V2 0/3] drivers/staging: zcache: dynamic page cache/swap compression
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Matt <jackdachef@gmail.com>, gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, linux-btrfs@vger.kernel.org, Josef Bacik <josef@redhat.com>, Dan Rosenberg <drosenberg@vsecurity.com>, Yan Zheng <zheng.z.yan@intel.com>, miaox@cn.fujitsu.com, Li Zefan <lizf@cn.fujitsu.com>

On Wed, Feb 16, 2011 at 10:27 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> -----Original Message-----
>> From: Matt [mailto:jackdachef@gmail.com]
>> Sent: Tuesday, February 15, 2011 5:12 PM
>> To: Minchan Kim
>> Cc: Dan Magenheimer; gregkh@suse.de; Chris Mason; linux-
>> kernel@vger.kernel.org; linux-mm@kvack.org; ngupta@vflare.org; linux-
>> btrfs@vger.kernel.org; Josef Bacik; Dan Rosenberg; Yan Zheng;
>> miaox@cn.fujitsu.com; Li Zefan
>> Subject: Re: [PATCH V2 0/3] drivers/staging: zcache: dynamic page
>> cache/swap compression
>>
>> On Mon, Feb 14, 2011 at 4:35 AM, Minchan Kim <minchan.kim@gmail.com>
>> > Just my guessing. I might be wrong.
>> >
>> > __cleancache_flush_inode calls cleancache_get_key with
>> cleancache_filekey.
>> > cleancache_file_key's size is just 6 * u32.
>> > cleancache_get_key calls btrfs_encode_fh with the key.
>> > but btrfs_encode_fh does typecasting the key to btrfs_fid which is
>> > bigger size than cleancache_filekey's one so it should not access
>> > fields beyond cleancache_get_key.
>> >
>> > I think some file systems use extend fid so in there, this problem
>> can
>> > happen. I don't know why we can't find it earlier. Maybe Dan and
>> > others test it for a long time.
>> >
>> > Am I missing something?
>> >
>> >
>> >
>> > --
>> > Kind regards,
>> > Minchan Kim
>> >
>>
>> reposting Minchan's message for reference to the btrfs mailing list
>> while also adding
>>
>> Li Zefan, Miao Xie, Yan Zheng, Dan Rosenberg and Josef Bacik to CC
>>
>> Regards
>>
>> Matt
>
> Hi Matt and Minchan --
>
> (BTRFS EXPERTS SEE *** BELOW)
>
> I definitely see a bug in cleancache_get_key in the monolithic
> zcache+cleancache+frontswap patch I posted on oss.oracle.com
> that is corrected in linux-next but I don't see how it could
> get provoked by btrfs.
>
> The bug is that, in cleancache_get_key, the return value of fhfn should
> be checked against 255. =C2=A0If the return value is 255, cleancache_get_=
key
> should return -1. =C2=A0This should disable cleancache for any filesystem
> where KEY_MAX is too large.
>
> But cleancache_get_key always calls fhfn with connectable =3D=3D 0 and
> CLEANCACHE_KEY_MAX=3D=3D6 should be greater than BTRFS_FID_SIZE_CONNECTAB=
LE
> (which I think should be 5?). =C2=A0And the elements written into the
> typecast btrfs_fid should be only writing the first 5 32-bit words.

BTRFS_FID_SIZE_NON_CONNECTALBE is 5,  not BTRFS_FID_SIZE_CONNECTABLE.
Anyway, you passed connectable with 0 so it should be only writing the
first 5 32-bit words as you said.
That's one I missed. ;-)

Thanks.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
