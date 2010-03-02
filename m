Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A363D6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 15:14:36 -0500 (EST)
Received: by qyk28 with SMTP id 28so451773qyk.14
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 12:14:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100302031021.GA14267@localhost>
References: <20100224024100.GA17048@localhost>
	 <20100224032934.GF16175@discord.disaster>
	 <20100224041822.GB27459@localhost>
	 <20100224052215.GH16175@discord.disaster>
	 <20100224061247.GA8421@localhost>
	 <20100224073940.GJ16175@discord.disaster>
	 <20100226074916.GA8545@localhost> <20100302031021.GA14267@localhost>
Date: Tue, 2 Mar 2010 12:14:33 -0800
Message-ID: <dda83e781003021214g6721c142o7c66f409296cf5a@mail.gmail.com>
Subject: Re: [RFC] nfs: use 4*rsize readahead size
From: Bret Towe <magnade@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 1, 2010 at 7:10 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> Dave,
>
> Here is one more test on a big ext4 disk file:
>
> =A0 =A0 =A0 =A0 =A0 16k =A039.7 MB/s
> =A0 =A0 =A0 =A0 =A0 32k =A054.3 MB/s
> =A0 =A0 =A0 =A0 =A0 64k =A063.6 MB/s
> =A0 =A0 =A0 =A0 =A0128k =A072.6 MB/s
> =A0 =A0 =A0 =A0 =A0256k =A071.7 MB/s
> rsize =3D=3D> 512k =A071.7 MB/s
> =A0 =A0 =A0 =A0 1024k =A072.2 MB/s
> =A0 =A0 =A0 =A0 2048k =A071.0 MB/s
> =A0 =A0 =A0 =A0 4096k =A073.0 MB/s
> =A0 =A0 =A0 =A0 8192k =A074.3 MB/s
> =A0 =A0 =A0 =A016384k =A074.5 MB/s
>
> It shows that >=3D128k client side readahead is enough for single disk
> case :) As for RAID configurations, I guess big server side readahead
> should be enough.
>
> #!/bin/sh
>
> file=3D/mnt/ext4_test/zero
> BDI=3D0:24
>
> for rasize in 16 32 64 128 256 512 1024 2048 4096 8192 16384
> do
> =A0 =A0 =A0 =A0echo $rasize > /sys/devices/virtual/bdi/$BDI/read_ahead_kb
> =A0 =A0 =A0 =A0echo readahead_size=3D${rasize}k
> =A0 =A0 =A0 =A0fadvise $file 0 0 dontneed
> =A0 =A0 =A0 =A0ssh p9 "fadvise $file 0 0 dontneed"
> =A0 =A0 =A0 =A0dd if=3D$file of=3D/dev/null bs=3D4k count=3D402400
> done

how do you determine which bdi to use? I skimmed thru
the filesystem in /sys and didn't see anything that says which is what

> Thanks,
> Fengguang
>
> On Fri, Feb 26, 2010 at 03:49:16PM +0800, Wu Fengguang wrote:
>> On Wed, Feb 24, 2010 at 03:39:40PM +0800, Dave Chinner wrote:
>> > On Wed, Feb 24, 2010 at 02:12:47PM +0800, Wu Fengguang wrote:
>> > > On Wed, Feb 24, 2010 at 01:22:15PM +0800, Dave Chinner wrote:
>> > > > What I'm trying to say is that while I agree with your premise tha=
t
>> > > > a 7.8MB readahead window is probably far larger than was ever
>> > > > intended, I disagree with your methodology and environment for
>> > > > selecting a better default value. =A0The default readahead value n=
eeds
>> > > > to work well in as many situations as possible, not just in perfec=
t
>> > > > 1:1 client/server environment.
>> > >
>> > > Good points. It's imprudent to change a default value based on one
>> > > single benchmark. Need to collect more data, which may take time..
>> >
>> > Agreed - better to spend time now to get it right...
>>
>> I collected more data with large network latency as well as rsize=3D32k,
>> and updates the readahead size accordingly to 4*rsize.
>>
>> =3D=3D=3D
>> nfs: use 2*rsize readahead size
>>
>> With default rsize=3D512k and NFS_MAX_READAHEAD=3D15, the current NFS
>> readahead size 512k*15=3D7680k is too large than necessary for typical
>> clients.
>>
>> On a e1000e--e1000e connection, I got the following numbers
>> (this reads sparse file from server and involves no disk IO)
>>
>> readahead size =A0 =A0 =A0 =A0normal =A0 =A0 =A0 =A0 =A01ms+1ms =A0 =A0 =
=A0 =A0 5ms+5ms =A0 =A0 =A0 =A0 10ms+10ms(*)
>> =A0 =A0 =A0 =A0 =A016k =A035.5 MB/s =A0 =A0 =A0 =A04.8 MB/s =A0 =A0 =A0 =
=A02.1 MB/s =A0 =A0 =A0 1.2 MB/s
>> =A0 =A0 =A0 =A0 =A032k =A054.3 MB/s =A0 =A0 =A0 =A06.7 MB/s =A0 =A0 =A0 =
=A03.6 MB/s =A0 =A0 =A0 2.3 MB/s
>> =A0 =A0 =A0 =A0 =A064k =A064.1 MB/s =A0 =A0 =A0 12.6 MB/s =A0 =A0 =A0 =
=A06.5 MB/s =A0 =A0 =A0 4.7 MB/s
>> =A0 =A0 =A0 =A0 128k =A070.5 MB/s =A0 =A0 =A0 20.1 MB/s =A0 =A0 =A0 11.9=
 MB/s =A0 =A0 =A0 8.7 MB/s
>> =A0 =A0 =A0 =A0 256k =A074.6 MB/s =A0 =A0 =A0 38.6 MB/s =A0 =A0 =A0 21.3=
 MB/s =A0 =A0 =A015.0 MB/s
>> rsize =3D=3D> 512k =A0 =A0 =A0 =A077.4 MB/s =A0 =A0 =A0 59.4 MB/s =A0 =
=A0 =A0 39.8 MB/s =A0 =A0 =A025.5 MB/s
>> =A0 =A0 =A0 =A01024k =A085.5 MB/s =A0 =A0 =A0 77.9 MB/s =A0 =A0 =A0 65.7=
 MB/s =A0 =A0 =A043.0 MB/s
>> =A0 =A0 =A0 =A02048k =A086.8 MB/s =A0 =A0 =A0 81.5 MB/s =A0 =A0 =A0 84.1=
 MB/s =A0 =A0 =A059.7 MB/s
>> =A0 =A0 =A0 =A04096k =A087.9 MB/s =A0 =A0 =A0 77.4 MB/s =A0 =A0 =A0 56.2=
 MB/s =A0 =A0 =A059.2 MB/s
>> =A0 =A0 =A0 =A08192k =A089.0 MB/s =A0 =A0 =A0 81.2 MB/s =A0 =A0 =A0 78.0=
 MB/s =A0 =A0 =A041.2 MB/s
>> =A0 =A0 =A0 16384k =A087.7 MB/s =A0 =A0 =A0 85.8 MB/s =A0 =A0 =A0 62.0 M=
B/s =A0 =A0 =A056.5 MB/s
>>
>> readahead size =A0 =A0 =A0 =A0normal =A0 =A0 =A0 =A0 =A01ms+1ms =A0 =A0 =
=A0 =A0 5ms+5ms =A0 =A0 =A0 =A0 10ms+10ms(*)
>> =A0 =A0 =A0 =A0 =A016k =A037.2 MB/s =A0 =A0 =A0 =A06.4 MB/s =A0 =A0 =A0 =
=A02.1 MB/s =A0 =A0 =A0 =A01.2 MB/s
>> rsize =3D=3D> =A032k =A0 =A0 =A0 =A056.6 MB/s =A0 =A0 =A0 =A06.8 MB/s =
=A0 =A0 =A0 =A03.6 MB/s =A0 =A0 =A0 =A02.3 MB/s
>> =A0 =A0 =A0 =A0 =A064k =A066.1 MB/s =A0 =A0 =A0 12.7 MB/s =A0 =A0 =A0 =
=A06.6 MB/s =A0 =A0 =A0 =A04.7 MB/s
>> =A0 =A0 =A0 =A0 128k =A069.3 MB/s =A0 =A0 =A0 22.0 MB/s =A0 =A0 =A0 12.2=
 MB/s =A0 =A0 =A0 =A08.9 MB/s
>> =A0 =A0 =A0 =A0 256k =A069.6 MB/s =A0 =A0 =A0 41.8 MB/s =A0 =A0 =A0 20.7=
 MB/s =A0 =A0 =A0 14.7 MB/s
>> =A0 =A0 =A0 =A0 512k =A071.3 MB/s =A0 =A0 =A0 54.1 MB/s =A0 =A0 =A0 25.0=
 MB/s =A0 =A0 =A0 16.9 MB/s
>> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^=
^^
>> =A0 =A0 =A0 =A01024k =A071.5 MB/s =A0 =A0 =A0 48.4 MB/s =A0 =A0 =A0 26.0=
 MB/s =A0 =A0 =A0 16.7 MB/s
>> =A0 =A0 =A0 =A02048k =A071.7 MB/s =A0 =A0 =A0 53.2 MB/s =A0 =A0 =A0 25.3=
 MB/s =A0 =A0 =A0 17.6 MB/s
>> =A0 =A0 =A0 =A04096k =A071.5 MB/s =A0 =A0 =A0 50.4 MB/s =A0 =A0 =A0 25.7=
 MB/s =A0 =A0 =A0 17.1 MB/s
>> =A0 =A0 =A0 =A08192k =A071.1 MB/s =A0 =A0 =A0 52.3 MB/s =A0 =A0 =A0 26.3=
 MB/s =A0 =A0 =A0 16.9 MB/s
>> =A0 =A0 =A0 16384k =A070.2 MB/s =A0 =A0 =A0 56.6 MB/s =A0 =A0 =A0 27.0 M=
B/s =A0 =A0 =A0 16.8 MB/s
>>
>> (*) 10ms+10ms means to add delay on both client & server sides with
>> =A0 =A0 # /sbin/tc qdisc change dev eth0 root netem delay 10ms
>> =A0 =A0 The total >=3D20ms delay is so large for NFS, that a simple `vi =
some.sh`
>> =A0 =A0 command takes a dozen seconds. Note that the actual delay report=
ed
>> =A0 =A0 by ping is larger, eg. for the 1ms+1ms case:
>> =A0 =A0 =A0 =A0 rtt min/avg/max/mdev =3D 7.361/8.325/9.710/0.837 ms
>>
>>
>> So it seems that readahead_size=3D4*rsize (ie. keep 4 RPC requests in
>> flight) is able to get near full NFS bandwidth. Reducing the mulriple
>> from 15 to 4 not only makes the client side readahead size more sane
>> (2MB by default), but also reduces the disorderness of the server side
>> RPC read requests, which yeilds better server side readahead behavior.
>>
>> To avoid small readahead when the client mount with "-o rsize=3D32k" or
>> the server only supports rsize <=3D 32k, we take the max of 2*rsize and
>> default_backing_dev_info.ra_pages. The latter defaults to 512K, and can
>> be explicitly changed by user with kernel parameter "readahead=3D" and
>> runtime tunable "/sys/devices/virtual/bdi/default/read_ahead_kb" (which
>> takes effective for future NFS mounts).
>>
>> The test script is:
>>
>> #!/bin/sh
>>
>> file=3D/mnt/sparse
>> BDI=3D0:15
>>
>> for rasize in 16 32 64 128 256 512 1024 2048 4096 8192 16384
>> do
>> =A0 =A0 =A0 echo 3 > /proc/sys/vm/drop_caches
>> =A0 =A0 =A0 echo $rasize > /sys/devices/virtual/bdi/$BDI/read_ahead_kb
>> =A0 =A0 =A0 echo readahead_size=3D${rasize}k
>> =A0 =A0 =A0 dd if=3D$file of=3D/dev/null bs=3D4k count=3D1024000
>> done
>>
>> CC: Dave Chinner <david@fromorbit.com>
>> CC: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>> ---
>> =A0fs/nfs/client.c =A0 | =A0 =A04 +++-
>> =A0fs/nfs/internal.h | =A0 =A08 --------
>> =A02 files changed, 3 insertions(+), 9 deletions(-)
>>
>> --- linux.orig/fs/nfs/client.c =A0 =A0 =A0 =A02010-02-26 10:10:46.000000=
000 +0800
>> +++ linux/fs/nfs/client.c =A0 =A0 2010-02-26 11:07:22.000000000 +0800
>> @@ -889,7 +889,9 @@ static void nfs_server_set_fsinfo(struct
>> =A0 =A0 =A0 server->rpages =3D (server->rsize + PAGE_CACHE_SIZE - 1) >> =
PAGE_CACHE_SHIFT;
>>
>> =A0 =A0 =A0 server->backing_dev_info.name =3D "nfs";
>> - =A0 =A0 server->backing_dev_info.ra_pages =3D server->rpages * NFS_MAX=
_READAHEAD;
>> + =A0 =A0 server->backing_dev_info.ra_pages =3D max_t(unsigned long,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 default_backing_dev_info.ra_pages,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 4 * server->rpages);
>> =A0 =A0 =A0 server->backing_dev_info.capabilities |=3D BDI_CAP_ACCT_UNST=
ABLE;
>>
>> =A0 =A0 =A0 if (server->wsize > max_rpc_payload)
>> --- linux.orig/fs/nfs/internal.h =A0 =A0 =A02010-02-26 10:10:46.00000000=
0 +0800
>> +++ linux/fs/nfs/internal.h =A0 2010-02-26 11:07:07.000000000 +0800
>> @@ -10,14 +10,6 @@
>>
>> =A0struct nfs_string;
>>
>> -/* Maximum number of readahead requests
>> - * FIXME: this should really be a sysctl so that users may tune it to s=
uit
>> - * =A0 =A0 =A0 =A0their needs. People that do NFS over a slow network, =
might for
>> - * =A0 =A0 =A0 =A0instance want to reduce it to something closer to 1 f=
or improved
>> - * =A0 =A0 =A0 =A0interactive response.
>> - */
>> -#define NFS_MAX_READAHEAD =A0 =A0(RPC_DEF_SLOT_TABLE - 1)
>> -
>> =A0/*
>> =A0 * Determine if sessions are in use.
>> =A0 */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
