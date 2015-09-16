Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6B86B0254
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 21:00:35 -0400 (EDT)
Received: by oiww128 with SMTP id w128so106281589oiw.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 18:00:35 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ar6si11461342obc.104.2015.09.15.18.00.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 18:00:34 -0700 (PDT)
From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Re: [PATCH 1/1] fs: global sync to not clear error status of
 individual inodes
Date: Wed, 16 Sep 2015 00:59:17 +0000
Message-ID: <20150916005916.GB6059@xzibit.linux.bs1.fc.nec.co.jp>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915152006.GD2905@mtj.duckdns.org>
In-Reply-To: <20150915152006.GD2905@mtj.duckdns.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <410CD4162C28C44ABCF7096797A356F2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 09/16/15 00:20, Tejun Heo wrote:
>> @@ -2121,7 +2121,13 @@ static void wait_sb_inodes(struct super_block *sb=
)
>>  		iput(old_inode);
>>  		old_inode =3D inode;
>> =20
>> -		filemap_fdatawait(mapping);
>> +		/*
>> +		 * Wait for on-going writeback to complete
>> +		 * but not consume error status on this mapping.
>                        ^don't
>=20
>> +		 * Otherwise application may fail to catch writeback error
>=20
>                    mapping; otherwise,
>=20
>> +		 * using fsync(2).
>> +		 */
>=20
> Can you please re-flow the comment so that it's filling up to, say, 72
> or 76 or whatever column?

I'll fix them.

>> -	filemap_fdatawait(bdev->bd_inode->i_mapping);
>> +	filemap_fdatawait_keep_errors(bdev->bd_inode->i_mapping);
>=20
> Maybe it'd be better to describe what's going on in detail in the
> function comment of filemat_fdatawait_keep_errors() and refer to that
> from its callers?

Thanks, that seems better.
I'll also extend function comments of filemap_fdatawait so that the
difference becomes clear.

--=20
Jun'ichi Nomura, NEC Corporation=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
