Subject: Re: 2.5.33-mm4 filemap_copy_from_user: Unexpected page fault
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3D78DD07.E36AE3A9@zip.com.au>
References: <1031327285.1984.155.camel@spc9.esa.lanl.gov>
	<3D78DD07.E36AE3A9@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 06 Sep 2002 11:03:23 -0600
Message-Id: <1031331803.2799.178.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2002-09-06 at 10:51, Andrew Morton wrote:
> Steven Cole wrote:
> > 
> > With 2.5.33-mm4, I tried running dbench on an ext2 partition and was
> > able to run up to dbench 80 successfully.  However, at dbench 96, I got
> > four messages like this:
> > 
> > filemap_copy_from_user: Unexpected page fault
> 
> Yep.  This means that the page we faulted in by-hand in generic_file_write()
> wasn't resident during the subsequent copy_from_user().
> 
> That fault-in by-hand is there to prevent a deadlock.  That printk
> meand that it isnt working all the time.   We have (always had) a
> problem.
> 
> > Shortly after this, the box hung again,
> > ...
> > >>EIP; c0159bf4 <sync_sb_inodes+84/260>   <=====
> > Trace; c0159e1e <writeback_inodes+4e/80>
> > Trace; c013b8aa <background_writeout+7a/c0>
> > Trace; c013b4cb <__pdflush+12b/1d0>
> 
> Hum.  Thanks for that.
> 
> I've been dbenching and compiling all night.  And yet, it
> seems that the dirty inode search in sync_sb_inodes() can trivially
> lock up.
> 
> Does this fix?
> 
>  fs-writeback.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
[patch snipped]

Unfortunately no.  With that patch, it got up to dbench 10 on ext3 and
then it hung again.

I haven't reboot the box yet in case the output from sysrq-p would be
useful.  It is a pain to type in though.

I had vmstat -n 1 1200 running in another terminal and here are the last
several lines of that output before the freeze:

 0  0  0      0 636688  25356  19192   0   0     0     0 1077  2983  19  44  37
10  0  0      0 589504  25856  65452   0   0    24     0 1022    41   2  37  61
 0 10  4      0 531940  26644 122060   0   0    12 22684 1194   431   6  51  42
 0 10  3      0 527316  26736 126592   0   0     4 12944 1189   246   2   7  91
 0 10  3      0 487488  27372 165676   0   0    12 15652 1238   569   7  41  52
 0 10  1      0 487476  27372 165676   0   0     0  4868 1167    84   0   3  97
 3  7  0      0 466636  27692 185728   0   0    20 12340 1188   202   6  24  70
 0 10  2      0 462580  27772 189280   0   0    20 13240 1302   282   1   7  91
 0 10  3      0 457832  27848 191244   0   0     8  9680 1350   334   2   5  93
 0 10  3      0 457448  27864 191564   0   0     4 10064 1406   277   0   2  99
 0 10  3      0 450812  27940 197804   0   0    12 12552 1382   351   2   6  92
 4  6  3      0 442804  28132 205204   0   0    12 21928 1231   721   7  17  75
 0 10  3      0 441248  28432 206376   0   0    12 18552 1195  5658  17  34  49
 0 10  2      0 440500  28468 206712   0   0     4  2288 1153   394   1   3  96
 9  3  5      0 438728  28580 207632   0   0    24 15100 1293   319   4  13  83

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
