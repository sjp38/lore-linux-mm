Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id A732B6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 19:10:33 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id pv20so4634723lab.7
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:10:33 -0800 (PST)
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com. [209.85.217.169])
        by mx.google.com with ESMTPS id n3si23449531lah.45.2015.01.22.16.10.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 16:10:32 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id f15so4476281lbj.0
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:10:31 -0800 (PST)
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
Date: Thu, 22 Jan 2015 19:10:31 -0500
Message-ID: <CANP1eJH4Kwq4wpc8_aa8VWuE43kLH1OrkePT4B33WPjet1Sp9Q@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Wed, Jan 21, 2015 at 4:17 PM, Jens Axboe <axboe@kernel.dk> wrote:
> On 01/20/2015 04:53 PM, Milosz Tanski wrote:
>>
>> On Tue, Jan 20, 2015 at 6:30 PM, Jens Axboe <axboe@kernel.dk> wrote:
>>>
>>> On 01/20/2015 04:26 PM, Jens Axboe wrote:
>>>>
>>>> On 01/20/2015 04:22 PM, Milosz Tanski wrote:
>>>>>
>>>>> Side note Jens.
>>>>>
>>>>> Can you add a configure flag to disable use of SHM (like for ESX)? It
>>>>> took me a while to figure out the proper define to manually stick in
>>>>> the configure.
>>>>>
>>>>> The motivation for this is using rr (mozila's replay debugger) to
>>>>> debug fio. rr doesn't support SHM. http://rr-project.org/ gdb's
>>>>> reversible debugging is too painfully slow.
>>>>
>>>>
>>>> Yeah definitely, that's mean that thread=1 would be a requirement,
>>>> obviously. But I'd be fine with adding that flag.
>>>
>>>
>>>
>>> http://git.kernel.dk/?p=fio.git;a=commit;h=ba40757ed67c00b37dda3639e97c3ba0259840a4
>>
>>
>> Great, thanks for fixing it so quickly. Hopefully it'll be useful to
>> others as well.
>
>
> No problem, it's in the 2.2.5 version as released. Let me know when you are
> comfortable with me pulling in the cifs engine.
>
Jermey, Volker,

Sorry for the spam to everybody in advance... this thread got away
from me. Also, sorry for dup message and HTML. Gmail decided to
upgrade my message from text to HTML in the middle of the thread; this
is like the Nth time this has happened to me in a year.


This is a general libsmbclient-raw question for you guys (even outside
the context of FIO). How should an external person consuming
libsmbclient-raw link to it?

What I mean by that is that that both linking to libsmbclient-raw and
via -llibsmbclient-raw or using pkgconfig doesn't really work do
missing. Using the current pkgconfig ends up with lot of missing
symbols at link time. It doesn't matter if I'm using samba built from
source or samba built from my distro package (Ubuntu or Debian).
There's a couple things so let me try to unpack them:

1. It doesn't seam like LDFLAGS pkgconfig setup in smbclient-raw.pc is correct.

It doesn't include dependent libraries that are needed like libtalloc,
libdcerpc, libsamba-credentials.so... and many more private libraries.
Please see below errors.

2. There's an intention is to have private building blocks split been
public and private libraries and it doesn't make sense (to me).

Some of the libraries go into $PREFIX/lib/ and some go in to
$PREFIX/lib/private (seams that it's $PREFIX/lib/samba when it's
packaged by distros like Debian/Ubuntu). However, some very basic
things (like handling of NTSTATUS) end up going into private libraries
like liberrors (get_friendly_nt_error_msg, nt_errstr). It's hard to
build error handling that prints a useful message without them.

It gets even more difficult, lpcfg_resolve_context() lives in private
libcli-ldap functions live and doesn't get mentioned in any headers in
$PREFIX/include. To the best of my knowledge it's not even possible to
make a successful call to smbcli_full_connection with passing in a
non-null resolve_context struct. And it seams like the only way to do
that is to call lpcfg_resolve_context(). Every example of a utility in
the samba tree that does smbcli_full_connection(), uses a
resolve_context created by lpcfg_resolve_context(). Believe me, I
tried a lot of different things and without getting a
NT_STATUS_INVALID_something.   smbcli_full_connection() seams to a
public function in a public library with a public header.


I can fix this and submit a patch / pull request to you guys; the
first one seams like an easy thing to tackle. The second one I need
more guidance on since I don't fully understand the intent / how did
you guys design the split.

This is what happens if I use pkgconfig:

gcc -rdynamic -std=gnu99 -Wwrite-strings -Wall
-Wdeclaration-after-statement -O3 -g -ffast-math  -D_GNU_SOURCE
-include config-host.h -DHAVE_IMMEDIATE_STRUCTURES=1
-I/usr/local/samba/include   -DBITS_PER_LONG=64
-DFIO_VERSION='"fio-2.1.11-23-g78d3d"' -o fio gettime.o ioengines.o
init.o stat.o log.o time.o filesetup.o eta.o verify.o memory.o io_u.o
parse.o mutex.o options.o lib/rbtree.o smalloc.o filehash.o profile.o
debug.o lib/rand.o lib/num2str.o lib/ieee754.o crc/crc16.o crc/crc32.o
crc/crc32c.o crc/crc32c-intel.o crc/crc64.o crc/crc7.o crc/md5.o
crc/sha1.o crc/sha256.o crc/sha512.o crc/test.o crc/xxhash.o
engines/cpu.o engines/mmap.o engines/sync.o engines/null.o
engines/net.o memalign.o server.o client.o iolog.o backend.o libfio.o
flow.o cconv.o lib/prio_tree.o json.o lib/zipf.o lib/axmap.o
lib/lfsr.o gettime-thread.o helpers.o lib/flist_sort.o lib/hweight.o
lib/getrusage.o idletime.o td_error.o profiles/tiobench.o
profiles/act.o io_u_queue.o filelock.o lib/tp.o engines/libaio.o
engines/posixaio.o engines/falloc.o engines/e4defrag.o
engines/splice.o engines/cifs.o engines/cifs_sync.o diskutil.o fifo.o
blktrace.o cgroup.o trim.o engines/sg.o engines/binject.o fio.o -lnuma
-libverbs -lrt -laio -lz  -Wl,-rpath,/usr/local/samba/lib
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
/home/mtanski/src/fio/engines/cifs.c:76: undefined reference to `gensec_init'
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
/home/mtanski/src/fio/engines/cifs.c:134: undefined reference to `_talloc_free'
engines/cifs.o: In function `fio_cifs_cleanup':
/home/mtanski/src/fio/engines/cifs.c:144: undefined reference to `smbcli_tdis'
engines/cifs.o: In function `fio_cifs_open_file':
/home/mtanski/src/fio/engines/cifs.c:174: undefined reference to `smbcli_open'
engines/cifs.o: In function `extend_file':
/home/mtanski/src/fio/engines/cifs.c:269: undefined reference to
`smbcli_getattrE'
/home/mtanski/src/fio/engines/cifs.c:318: undefined reference to `smbcli_write'
/home/mtanski/src/fio/engines/cifs.c:284: undefined reference to
`smbcli_ftruncate'
/home/mtanski/src/fio/engines/cifs.c:288: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:288: undefined reference to
`get_friendly_nt_error_msg'
/home/mtanski/src/fio/engines/cifs.c:273: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:273: undefined reference to
`get_friendly_nt_error_msg'
engines/cifs.o: In function `fio_cifs_close_file':
/home/mtanski/src/fio/engines/cifs.c:192: undefined reference to `smbcli_close'
/home/mtanski/src/fio/engines/cifs.c:195: undefined reference to `nt_errstr'
/home/mtanski/src/fio/engines/cifs.c:195: undefined reference to
`get_friendly_nt_error_msg'
engines/cifs.o: In function `fio_cifs_unlink_file':
/home/mtanski/src/fio/engines/cifs.c:213: undefined reference to `smbcli_unlink'
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
/home/mtanski/src/fio/engines/cifs.c:145: undefined reference to `_talloc_free'
collect2: error: ld returned 1 exit status

-- 
Milosz Tanski
CTO
16 East 34th Street, 15th floor
New York, NY 10016

p: 646-253-9055
e: milosz@adfin.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
