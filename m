Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.59-mm5
Date: Sat, 25 Jan 2003 22:51:14 -0500
References: <20030123195044.47c51d39.akpm@digeo.com> <200301252043.09642.tomlins@cam.org> <20030125181701.312826e5.akpm@digeo.com>
In-Reply-To: <20030125181701.312826e5.akpm@digeo.com>
MIME-Version: 1.0
Message-Id: <200301252251.14860.tomlins@cam.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, green@namesys.com
List-ID: <linux-mm.kvack.org>

On January 25, 2003 09:17 pm, Andrew Morton wrote:
> Is this different from 2.5.59 base?

Same in 59 and as far back as 51(ish) which is the oldest that I 
have prebuilt here...

> It's beginning to look like copy_foo_user() itself has gone silly.
>
> I don't know what's causing this, Ed.  Could you please dig into it a
> little more?  Does it happen with a bare `dd'?  Or is it networking?
>  etcetera...

What I see is this.

apt installs squidguard

squidguard starts 5 processes 

atp installs chastity-list

and the squidguard processes proceed to take most of the cpu.  Each 
of the squidguard processes takes about 17% of the cpu.  These keep 
running after apt finshes and the system time drops when they end...

I started a strace of one of the offending processes and saw lots like:

pread(6, "\0\0\0\0\1\0\0\0\325\0\0\0\243\0\0\0\267\0\0\0t\1@\16\1"..., 8192, 1744896) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\267\0\0\0\325\0\0\0\320\0\0\0000\2\270"..., 8192, 1499136) = 8192
pread(6, "\0\0\0\0\1\0\0\0\305\0\0\0\330\0\0\0\332\0\0\0d\1\f\16"..., 8192, 1613824) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\273\0\0\0\323\0\0\0\327\0\0\0n\1\210\r"..., 8192, 1531904) = 8192
pread(6, "\0\0\0\0\1\0\0\0\330\0\0\0\10\0\0\0\305\0\0\0j\1`\r\1\5"..., 8192, 1769472) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\342\0\0\0\303\0\0\0\262\0\0\0.\1\314\20"..., 8192, 1851392) = 8192
pread(6, "\0\0\0\0\1\0\0\0\346\0\0\0\310\0\0\0\266\0\0\0X\1$\20\1"..., 8192, 1884160) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\6\0\0\0\317\0\0\0\315\0\0\0\34\2d\4\1"..., 8192, 49152) = 8192
pread(6, "\0\0\0\0\1\0\0\0\5\0\0\0\363\0\0\0\362\0\0\0$\1\224\21"..., 8192, 40960) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\10\0\0\0\341\0\0\0\330\0\0\0\220\1\230"..., 8192, 65536) = 8192
pread(6, "\0\0\0\0\1\0\0\0\331\0\0\0\277\0\0\0\250\0\0\0b\1l\r\1"..., 8192, 1777664) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\350\0\0\0\37\0\0\0\303\0\0\0H\1`\20\1"..., 8192, 1900544) = 8192
pread(6, "\0\0\0\0\1\0\0\0\267\0\0\0\325\0\0\0\320\0\0\0000\2\270"..., 8192, 1499136) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\310\0\0\0\362\0\0\0\346\0\0\0B\1|\20\1"..., 8192, 1638400) = 8192
pread(6, "\0\0\0\0\1\0\0\0\302\0\0\0\326\0\0\0\335\0\0\0l\1\354\16"..., 8192, 1589248) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\313\0\0\0\356\0\0\0\270\0\0\0\26\2\254"..., 8192, 1662976) = 8192
pread(6, "\0\0\0\0\1\0\0\0\307\0\0\0\354\0\0\0\347\0\0\0N\1l\17\1"..., 8192, 1630208) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\314\0\0\0\361\0\0\0\265\0\0\0\24\2d\4"..., 8192, 1671168) = 8192
pread(6, "\0\0\0\0\1\0\0\0\10\0\0\0\341\0\0\0\330\0\0\0\220\1\230"..., 8192, 65536) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\321\0\0\0\266\0\0\0\243\0\0\0p\1\320\r"..., 8192, 1712128) = 8192
pread(6, "\0\0\0\0\1\0\0\0\336\0\0\0 \0\0\0\300\0\0\0>\0010\17\1"..., 8192, 1818624) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\322\0\0\0\272\0\0\0\244\0\0\0\274\1`\t"..., 8192, 1720320) = 8192
pread(6, "\0\0\0\0\1\0\0\0\4\0\0\0\344\0\0\0\361\0\0\0(\1\240\21"..., 8192, 32768) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\262\0\0\0\342\0\0\0\316\0\0\0\350\1\340"..., 8192, 1458176) = 8192
pread(6, "\0\0\0\0\1\0\0\0\324\0\0\0\274\0\0\0!\0\0\0\250\1\220\f"..., 8192, 1736704) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0!\0\0\0\324\0\0\0\356\0\0\0008\1p\21\1"..., 8192, 270336) = 8192
pread(6, "\0\0\0\0\1\0\0\0\310\0\0\0\362\0\0\0\346\0\0\0B\1|\20\1"..., 8192, 1638400) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\271\0\0\0\347\0\0\0\326\0\0\0\202\1\334"..., 8192, 1515520) = 8192
pread(6, "\0\0\0\0\1\0\0\0\266\0\0\0\346\0\0\0\321\0\0\0t\1\354\v"..., 8192, 1490944) = 8192
pwrite(6, "\0\0\0\0\1\0\0\0\3\0\0\0\351\0\0\0\357\0\0\0\"\1\270\20"..., 8192, 24576) = 8192

Does this help?

Ed





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
