Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7416D6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 19:03:42 -0500 (EST)
Received: by mail-lb0-f172.google.com with SMTP id l4so4450670lbv.3
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:03:41 -0800 (PST)
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com. [209.85.217.172])
        by mx.google.com with ESMTPS id ny7si21941103lbb.135.2015.01.22.16.03.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 16:03:40 -0800 (PST)
Received: by mail-lb0-f172.google.com with SMTP id l4so4450567lbv.3
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:03:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54C0174C.9060203@kernel.dk>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<20150115223157.GB25884@quack.suse.cz>
	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
	<20150116165506.GA10856@samba2>
	<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
	<20150119071218.GA9747@jeremy-HP>
	<1421652849.2080.20.camel@HansenPartnership.com>
	<CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
	<54BD234F.3060203@kernel.dk>
	<54BEAD82.3070501@kernel.dk>
	<CANP1eJG36DYG8xezydcuWAw6d-Khz9ULr9WMuJ6kfpPzJEoOXw@mail.gmail.com>
	<CANP1eJHqhYZ9_yf16LKaUMvHEJN7eERpKSBYVrtQhr8ZkGVVsQ@mail.gmail.com>
	<54BEE436.4020205@kernel.dk>
	<54BEE51F.7080400@kernel.dk>
	<CANP1eJH=-ounu9RCtWntnS4nLFVZYaUJg26AUn1=MZFCpeVFTQ@mail.gmail.com>
	<54C0174C.9060203@kernel.dk>
Date: Thu, 22 Jan 2015 19:03:39 -0500
Message-ID: <CANP1eJHDCxM-rEBXqt=cEcCnWvJ4sFWQYRVE7Svt2iSqqUvAvA@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: multipart/alternative; boundary=089e0160a3b6591df0050d4685c9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, samba-technical@lists.samba.org

--089e0160a3b6591df0050d4685c9
Content-Type: text/plain; charset=UTF-8

On Wed, Jan 21, 2015 at 4:17 PM, Jens Axboe <axboe@kernel.dk> wrote:

> On 01/20/2015 04:53 PM, Milosz Tanski wrote:
>
>> On Tue, Jan 20, 2015 at 6:30 PM, Jens Axboe <axboe@kernel.dk> wrote:
>>
>>> On 01/20/2015 04:26 PM, Jens Axboe wrote:
>>>
>>>> On 01/20/2015 04:22 PM, Milosz Tanski wrote:
>>>>
>>>>> Side note Jens.
>>>>>
>>>>> Can you add a configure flag to disable use of SHM (like for ESX)? It
>>>>> took me a while to figure out the proper define to manually stick in
>>>>> the configure.
>>>>>
>>>>> The motivation for this is using rr (mozila's replay debugger) to
>>>>> debug fio. rr doesn't support SHM. http://rr-project.org/ gdb's
>>>>> reversible debugging is too painfully slow.
>>>>>
>>>>
>>>> Yeah definitely, that's mean that thread=1 would be a requirement,
>>>> obviously. But I'd be fine with adding that flag.
>>>>
>>>
>>> http://git.kernel.dk/?p=fio.git;a=commit;h=
>>> ba40757ed67c00b37dda3639e97c3ba0259840a4
>>>
>>
>> Great, thanks for fixing it so quickly. Hopefully it'll be useful to
>> others as well.
>>
>
> No problem, it's in the 2.2.5 version as released. Let me know when you
> are comfortable with me pulling in the cifs engine.


Jermey, Volker,

Sorry for the spam to everybody in advance... this thread got away from me.


This is a general libsmbclient-raw question for you guys (even outside the
context of FIO). How should an external person consuming libsmbclient-raw
link to it?

What I mean by that is that that both linking to libsmbclient-raw and via
-llibsmbclient-raw or using pkgconfig doesn't really work do missing. Using
the current pkgconfig ends up with lot of missing symbols at link time. It
doesn't matter if I'm using samba built from source or samba built from my
distro package (Ubuntu or Debian). There's a couple things so let me try to
unpack them:

1. It doesn't seam like LDFLAGS pkgconfig setup in smbclient-raw.pc is
correct.

It doesn't include dependent libraries that are needed like libtalloc,
libdcerpc, libsamba-credentials.so... and many more private libraries.
Please see below errors.

2. There's an intention is to have private building blocks split been
public and private libraries and it doesn't make sense (to me).

Some of the libraries go into $PREFIX/lib/ and some go in to
$PREFIX/lib/private (seams that it's $PREFIX/lib/samba when it's packaged
by distros like Debian/Ubuntu). However, some very basic things (like
handling of NTSTATUS) end up going into private libraries like liberrors
(get_friendly_nt_error_msg, nt_errstr). It's hard to build error handling
that prints a useful message without them.

It gets even more difficult, lpcfg_resolve_context() lives in private
libcli-ldap functions live and doesn't get mentioned in any headers in
$PREFIX/include. To the best of my knowledge it's not even possible to make
a successful call to smbcli_full_connection with passing in a non-null
resolve_context struct. And it seams like the only way to do that is to
call lpcfg_resolve_context(). Every example of a utility in the samba tree
that does smbcli_full_connection(), uses a resolve_context created by
lpcfg_resolve_context(). Believe me, I tried a lot of different things and
without getting a NT_STATUS_INVALID_something.   smbcli_full_connection()
seams to a public function in a public library with a public header.


I can fix this and submit a patch / pull request to you guys; the first one
seams like an easy thing to tackle. The second one I need more guidance on
since I don't fully understand the intent / how did you guys design the
split.

This is what happens if I use pkgconfig:

gcc -rdynamic -std=gnu99 -Wwrite-strings -Wall
-Wdeclaration-after-statement -O3 -g -ffast-math  -D_GNU_SOURCE -include
config-host.h -DHAVE_IMMEDIATE_STRUCTURES=1 -I/usr/local/samba/include
-DBITS_PER_LONG=64 -DFIO_VERSION='"fio-2.1.11-23-g78d3d"' -o fio gettime.o
ioengines.o init.o stat.o log.o time.o filesetup.o eta.o verify.o memory.o
io_u.o parse.o mutex.o options.o lib/rbtree.o smalloc.o filehash.o
profile.o debug.o lib/rand.o lib/num2str.o lib/ieee754.o crc/crc16.o
crc/crc32.o crc/crc32c.o crc/crc32c-intel.o crc/crc64.o crc/crc7.o
crc/md5.o crc/sha1.o crc/sha256.o crc/sha512.o crc/test.o crc/xxhash.o
engines/cpu.o engines/mmap.o engines/sync.o engines/null.o engines/net.o
memalign.o server.o client.o iolog.o backend.o libfio.o flow.o cconv.o
lib/prio_tree.o json.o lib/zipf.o lib/axmap.o lib/lfsr.o gettime-thread.o
helpers.o lib/flist_sort.o lib/hweight.o lib/getrusage.o idletime.o
td_error.o profiles/tiobench.o profiles/act.o io_u_queue.o filelock.o
lib/tp.o engines/libaio.o engines/posixaio.o engines/falloc.o
engines/e4defrag.o engines/splice.o engines/cifs.o engines/cifs_sync.o
diskutil.o fifo.o blktrace.o cgroup.o trim.o engines/sg.o engines/binject.o
fio.o -lnuma -libverbs -lrt -laio -lz  -Wl,-rpath,/usr/local/samba/lib
-L/usr/local/samba/lib -lsmbclient-raw   -lm  -lpthread -ldl
engines/cifs_sync.o: In function `fio_cifs_queue':
/home/mtanski/src/fio/engines/cifs_sync.c:47: undefined reference to
`smbcli_write'
/home/mtanski/src/fio/engines/cifs_sync.c:43: undefined reference to
`smbcli_read'
engines/cifs.o: In function `fio_cifs_init':
/home/mtanski/src/fio/engines/cifs.c:64: undefined reference to
`talloc_named_const'
/home/mtanski/src/fio/engines/cifs.c:73: undefined reference to
`samba_tevent_context_init'
/home/mtanski/src/fio/engines/cifs.c:76: undefined reference to
`gensec_init'
/home/mtanski/src/fio/engines/cifs.c:78: undefined reference to
`loadparm_init_global'
/home/mtanski/src/fio/engines/cifs.c:79: undefined reference to
`lpcfg_load_default'
/home/mtanski/src/fio/engines/cifs.c:80: undefined reference to
`lpcfg_smbcli_options'
/home/mtanski/src/fio/engines/cifs.c:81: undefined reference to
`lpcfg_smbcli_session_options'
/home/mtanski/src/fio/engines/cifs.c:84: undefined reference to
`cli_credentials_init'
/home/mtanski/src/fio/engines/cifs.c:85: undefined reference to
`cli_credentials_set_anonymous'
/home/mtanski/src/fio/engines/cifs.c:88: undefined reference to
`cli_credentials_parse_string'
/home/mtanski/src/fio/engines/cifs.c:95: undefined reference to
`cli_credentials_set_password'
/home/mtanski/src/fio/engines/cifs.c:103: undefined reference to
`cli_credentials_guess'
/home/mtanski/src/fio/engines/cifs.c:105: undefined reference to
`lpcfg_gensec_settings'
/home/mtanski/src/fio/engines/cifs.c:105: undefined reference to
`lpcfg_resolve_context'
/home/mtanski/src/fio/engines/cifs.c:105: undefined reference to
`lpcfg_socket_options'
/home/mtanski/src/fio/engines/cifs.c:105: undefined reference to
`lpcfg_smb_ports'
/home/mtanski/src/fio/engines/cifs.c:105: undefined reference to
`smbcli_full_connection'
/home/mtanski/src/fio/engines/cifs.c:122: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:122: undefined reference to
`get_friendly_nt_error_msg'
/home/mtanski/src/fio/engines/cifs.c:134: undefined reference to
`_talloc_free'
engines/cifs.o: In function `fio_cifs_cleanup':
/home/mtanski/src/fio/engines/cifs.c:144: undefined reference to
`smbcli_tdis'
engines/cifs.o: In function `fio_cifs_open_file':
/home/mtanski/src/fio/engines/cifs.c:174: undefined reference to
`smbcli_open'
engines/cifs.o: In function `extend_file':
/home/mtanski/src/fio/engines/cifs.c:269: undefined reference to
`smbcli_getattrE'
/home/mtanski/src/fio/engines/cifs.c:318: undefined reference to
`smbcli_write'
/home/mtanski/src/fio/engines/cifs.c:284: undefined reference to
`smbcli_ftruncate'
/home/mtanski/src/fio/engines/cifs.c:288: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:288: undefined reference to
`get_friendly_nt_error_msg'
/home/mtanski/src/fio/engines/cifs.c:273: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:273: undefined reference to
`get_friendly_nt_error_msg'
engines/cifs.o: In function `fio_cifs_close_file':
/home/mtanski/src/fio/engines/cifs.c:192: undefined reference to
`smbcli_close'
/home/mtanski/src/fio/engines/cifs.c:195: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:195: undefined reference to
`get_friendly_nt_error_msg'
engines/cifs.o: In function `fio_cifs_unlink_file':
/home/mtanski/src/fio/engines/cifs.c:213: undefined reference to
`smbcli_unlink'
/home/mtanski/src/fio/engines/cifs.c:216: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:216: undefined reference to
`get_friendly_nt_error_msg'
engines/cifs.o: In function `fio_cifs_get_file_size':
/home/mtanski/src/fio/engines/cifs.c:238: undefined reference to
`smbcli_getattrE'
/home/mtanski/src/fio/engines/cifs.c:242: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:242: undefined reference to
`get_friendly_nt_error_msg'
engines/cifs.o: In function `fio_cifs_cleanup':
/home/mtanski/src/fio/engines/cifs.c:145: undefined reference to
`_talloc_free'
collect2: error: ld returned 1 exit status

-- 
Milosz Tanski
CTO
16 East 34th Street, 15th floor
New York, NY 10016

p: 646-253-9055
e: milosz@adfin.com

--089e0160a3b6591df0050d4685c9
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On W=
ed, Jan 21, 2015 at 4:17 PM, Jens Axboe <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:axboe@kernel.dk" target=3D"_blank">axboe@kernel.dk</a>&gt;</span> wrot=
e:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;b=
order-left-width:1px;border-left-color:rgb(204,204,204);border-left-style:s=
olid;padding-left:1ex"><span class=3D"">On 01/20/2015 04:53 PM, Milosz Tans=
ki wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
On Tue, Jan 20, 2015 at 6:30 PM, Jens Axboe &lt;<a href=3D"mailto:axboe@ker=
nel.dk" target=3D"_blank">axboe@kernel.dk</a>&gt; wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
On 01/20/2015 04:26 PM, Jens Axboe wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
On 01/20/2015 04:22 PM, Milosz Tanski wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
Side note Jens.<br>
<br>
Can you add a configure flag to disable use of SHM (like for ESX)? It<br>
took me a while to figure out the proper define to manually stick in<br>
the configure.<br>
<br>
The motivation for this is using rr (mozila&#39;s replay debugger) to<br>
debug fio. rr doesn&#39;t support SHM. <a href=3D"http://rr-project.org/" t=
arget=3D"_blank">http://rr-project.org/</a> gdb&#39;s<br>
reversible debugging is too painfully slow.<br>
</blockquote>
<br>
Yeah definitely, that&#39;s mean that thread=3D1 would be a requirement,<br=
>
obviously. But I&#39;d be fine with adding that flag.<br>
</blockquote>
<br>
<a href=3D"http://git.kernel.dk/?p=3Dfio.git;a=3Dcommit;h=3Dba40757ed67c00b=
37dda3639e97c3ba0259840a4" target=3D"_blank">http://git.kernel.dk/?p=3Dfio.=
<u></u>git;a=3Dcommit;h=3D<u></u>ba40757ed67c00b37dda3639e97c3b<u></u>a0259=
840a4</a><br>
</blockquote>
<br>
Great, thanks for fixing it so quickly. Hopefully it&#39;ll be useful to<br=
>
others as well.<br>
</blockquote>
<br></span>
No problem, it&#39;s in the 2.2.5 version as released. Let me know when you=
 are comfortable with me pulling in the cifs engine.</blockquote><div><br><=
/div><div>Jermey, Volker,</div><div><br></div><div>Sorry for the spam to ev=
erybody in advance... this thread got away from me.</div><div><br></div><di=
v><br></div><div>This is a general libsmbclient-raw question for you guys (=
even outside the context of FIO). How should an external person consuming l=
ibsmbclient-raw link to it?</div><div><br></div><div>What I mean by that is=
 that that both linking to libsmbclient-raw and via -llibsmbclient-raw or u=
sing pkgconfig doesn&#39;t really work do missing. Using the current pkgcon=
fig ends up with lot of missing symbols at link time. It doesn&#39;t matter=
 if I&#39;m using samba built from source or samba built from my distro pac=
kage (Ubuntu or Debian). There&#39;s a couple things so let me try to unpac=
k them:</div><div><br></div><div>1. It doesn&#39;t seam like LDFLAGS pkgcon=
fig setup in smbclient-raw.pc is correct.</div><div><br></div><div>It doesn=
&#39;t include dependent libraries that are needed like libtalloc, libdcerp=
c, libsamba-credentials.so... and many more private libraries. Please see b=
elow errors.<br></div><div><br></div><div>2. There&#39;s an intention is to=
 have private building blocks split been public and private libraries and i=
t doesn&#39;t make sense (to me).</div><div><br></div><div>Some of the libr=
aries go into $PREFIX/lib/ and some go in to $PREFIX/lib/private (seams tha=
t it&#39;s $PREFIX/lib/samba when it&#39;s=C2=A0packaged by distros like De=
bian/Ubuntu). However, some very basic things (like handling of NTSTATUS) e=
nd up going into private libraries like liberrors (get_friendly_nt_error_ms=
g, nt_errstr). It&#39;s hard to build error handling that prints a useful m=
essage without them.</div><div><br></div><div>It gets even more difficult, =
lpcfg_resolve_context() lives in private libcli-ldap functions live and doe=
sn&#39;t get mentioned in any headers in $PREFIX/include. To the best of my=
 knowledge it&#39;s not even possible to make a successful call to smbcli_f=
ull_connection with passing in a non-null resolve_context struct. And it se=
ams like the only way to do that is to call lpcfg_resolve_context(). Every =
example of a utility in the samba tree that does smbcli_full_connection(), =
uses a resolve_context created by lpcfg_resolve_context(). Believe me, I tr=
ied a lot of different things and without getting a NT_STATUS_INVALID_somet=
hing. =C2=A0 smbcli_full_connection() seams to a public function in a publi=
c library with a public header.</div><div><br></div><div><br></div><div>I c=
an fix this and submit a patch / pull request to you guys; the first one se=
ams like an easy thing to tackle. The second one I need more guidance on si=
nce I don&#39;t fully understand the intent / how did you guys design the s=
plit.<br></div><div><br></div><div>This is what happens if I use pkgconfig:=
</div><div><br></div><div><div>gcc -rdynamic -std=3Dgnu99 -Wwrite-strings -=
Wall -Wdeclaration-after-statement -O3 -g -ffast-math =C2=A0-D_GNU_SOURCE -=
include config-host.h -DHAVE_IMMEDIATE_STRUCTURES=3D1 -I/usr/local/samba/in=
clude =C2=A0 -DBITS_PER_LONG=3D64 -DFIO_VERSION=3D&#39;&quot;fio-2.1.11-23-=
g78d3d&quot;&#39; -o fio gettime.o ioengines.o init.o stat.o log.o time.o f=
ilesetup.o eta.o verify.o memory.o io_u.o parse.o mutex.o options.o lib/rbt=
ree.o smalloc.o filehash.o profile.o debug.o lib/rand.o lib/num2str.o lib/i=
eee754.o crc/crc16.o crc/crc32.o crc/crc32c.o crc/crc32c-intel.o crc/crc64.=
o crc/crc7.o crc/md5.o crc/sha1.o crc/sha256.o crc/sha512.o crc/test.o crc/=
xxhash.o engines/cpu.o engines/mmap.o engines/sync.o engines/null.o engines=
/net.o memalign.o server.o client.o iolog.o backend.o libfio.o flow.o cconv=
.o lib/prio_tree.o json.o lib/zipf.o lib/axmap.o lib/lfsr.o gettime-thread.=
o helpers.o lib/flist_sort.o lib/hweight.o lib/getrusage.o idletime.o td_er=
ror.o profiles/tiobench.o profiles/act.o io_u_queue.o filelock.o lib/tp.o e=
ngines/libaio.o engines/posixaio.o engines/falloc.o engines/e4defrag.o engi=
nes/splice.o engines/cifs.o engines/cifs_sync.o diskutil.o fifo.o blktrace.=
o cgroup.o trim.o engines/sg.o engines/binject.o fio.o -lnuma -libverbs -lr=
t -laio -lz =C2=A0-Wl,-rpath,/usr/local/samba/lib -L/usr/local/samba/lib -l=
smbclient-raw =C2=A0 -lm =C2=A0-lpthread -ldl=C2=A0</div><div>engines/cifs_=
sync.o: In function `fio_cifs_queue&#39;:</div><div>/home/mtanski/src/fio/e=
ngines/cifs_sync.c:47: undefined reference to `smbcli_write&#39;</div><div>=
/home/mtanski/src/fio/engines/cifs_sync.c:43: undefined reference to `smbcl=
i_read&#39;</div><div>engines/cifs.o: In function `fio_cifs_init&#39;:</div=
><div>/home/mtanski/src/fio/engines/cifs.c:64: undefined reference to `tall=
oc_named_const&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:73: unde=
fined reference to `samba_tevent_context_init&#39;</div><div>/home/mtanski/=
src/fio/engines/cifs.c:76: undefined reference to `gensec_init&#39;</div><d=
iv>/home/mtanski/src/fio/engines/cifs.c:78: undefined reference to `loadpar=
m_init_global&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:79: undef=
ined reference to `lpcfg_load_default&#39;</div><div>/home/mtanski/src/fio/=
engines/cifs.c:80: undefined reference to `lpcfg_smbcli_options&#39;</div><=
div>/home/mtanski/src/fio/engines/cifs.c:81: undefined reference to `lpcfg_=
smbcli_session_options&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:=
84: undefined reference to `cli_credentials_init&#39;</div><div>/home/mtans=
ki/src/fio/engines/cifs.c:85: undefined reference to `cli_credentials_set_a=
nonymous&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:88: undefined =
reference to `cli_credentials_parse_string&#39;</div><div>/home/mtanski/src=
/fio/engines/cifs.c:95: undefined reference to `cli_credentials_set_passwor=
d&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:103: undefined refere=
nce to `cli_credentials_guess&#39;</div><div>/home/mtanski/src/fio/engines/=
cifs.c:105: undefined reference to `lpcfg_gensec_settings&#39;</div><div>/h=
ome/mtanski/src/fio/engines/cifs.c:105: undefined reference to `lpcfg_resol=
ve_context&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:105: undefin=
ed reference to `lpcfg_socket_options&#39;</div><div>/home/mtanski/src/fio/=
engines/cifs.c:105: undefined reference to `lpcfg_smb_ports&#39;</div><div>=
/home/mtanski/src/fio/engines/cifs.c:105: undefined reference to `smbcli_fu=
ll_connection&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:122: unde=
fined reference to `nt_errstr&#39;</div><div>/home/mtanski/src/fio/engines/=
cifs.c:122: undefined reference to `get_friendly_nt_error_msg&#39;</div><di=
v>/home/mtanski/src/fio/engines/cifs.c:134: undefined reference to `_talloc=
_free&#39;</div><div>engines/cifs.o: In function `fio_cifs_cleanup&#39;:</d=
iv><div>/home/mtanski/src/fio/engines/cifs.c:144: undefined reference to `s=
mbcli_tdis&#39;</div><div>engines/cifs.o: In function `fio_cifs_open_file&#=
39;:</div><div>/home/mtanski/src/fio/engines/cifs.c:174: undefined referenc=
e to `smbcli_open&#39;</div><div>engines/cifs.o: In function `extend_file&#=
39;:</div><div>/home/mtanski/src/fio/engines/cifs.c:269: undefined referenc=
e to `smbcli_getattrE&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:3=
18: undefined reference to `smbcli_write&#39;</div><div>/home/mtanski/src/f=
io/engines/cifs.c:284: undefined reference to `smbcli_ftruncate&#39;</div><=
div>/home/mtanski/src/fio/engines/cifs.c:288: undefined reference to `nt_er=
rstr&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:288: undefined ref=
erence to `get_friendly_nt_error_msg&#39;</div><div>/home/mtanski/src/fio/e=
ngines/cifs.c:273: undefined reference to `nt_errstr&#39;</div><div>/home/m=
tanski/src/fio/engines/cifs.c:273: undefined reference to `get_friendly_nt_=
error_msg&#39;</div><div>engines/cifs.o: In function `fio_cifs_close_file&#=
39;:</div><div>/home/mtanski/src/fio/engines/cifs.c:192: undefined referenc=
e to `smbcli_close&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:195:=
 undefined reference to `nt_errstr&#39;</div><div>/home/mtanski/src/fio/eng=
ines/cifs.c:195: undefined reference to `get_friendly_nt_error_msg&#39;</di=
v><div>engines/cifs.o: In function `fio_cifs_unlink_file&#39;:</div><div>/h=
ome/mtanski/src/fio/engines/cifs.c:213: undefined reference to `smbcli_unli=
nk&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:216: undefined refer=
ence to `nt_errstr&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:216:=
 undefined reference to `get_friendly_nt_error_msg&#39;</div><div>engines/c=
ifs.o: In function `fio_cifs_get_file_size&#39;:</div><div>/home/mtanski/sr=
c/fio/engines/cifs.c:238: undefined reference to `smbcli_getattrE&#39;</div=
><div>/home/mtanski/src/fio/engines/cifs.c:242: undefined reference to `nt_=
errstr&#39;</div><div>/home/mtanski/src/fio/engines/cifs.c:242: undefined r=
eference to `get_friendly_nt_error_msg&#39;</div><div>engines/cifs.o: In fu=
nction `fio_cifs_cleanup&#39;:</div><div>/home/mtanski/src/fio/engines/cifs=
.c:145: undefined reference to `_talloc_free&#39;</div><div>collect2: error=
: ld returned 1 exit status</div></div><div><br></div></div>-- <br><div cla=
ss=3D"gmail_signature"><div dir=3D"ltr">Milosz Tanski<br>CTO<br>16 East 34t=
h Street, 15th floor<br>New York, NY 10016<br><br>p: 646-253-9055<br>e: <a =
href=3D"mailto:milosz@adfin.com" target=3D"_blank">milosz@adfin.com</a><br>=
</div></div>
</div></div>

--089e0160a3b6591df0050d4685c9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
