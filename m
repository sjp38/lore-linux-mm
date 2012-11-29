Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id AC4246B004D
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 01:53:08 -0500 (EST)
From: Jim Meyering <jim@meyering.net>
Subject: Re: [PATCH] tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
In-Reply-To: <50B6E7CB.1040504@oracle.com> (Jeff Liu's message of "Thu, 29 Nov
	2012 12:42:51 +0800")
References: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils>
	<20121129012933.GA9112@kernel>
	<alpine.LNX.2.00.1211281745200.1641@eggly.anvils>
	<87lidlxcw9.fsf@rho.meyering.net> <50B6E7CB.1040504@oracle.com>
Date: Thu, 29 Nov 2012 07:53:06 +0100
Message-ID: <87d2yw3not.fsf@rho.meyering.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Jaegeuk Hanse <jaegeuk.hanse@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Zheng Liu <wenqing.lz@taobao.com>, Paul Eggert <eggert@cs.ucla.edu>, Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Dave Chinner <david@fromorbit.com>, Marco Stornelli <marco.stornelli@gmail.com>, Chris Mason <chris.mason@fusionio.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Jeff Liu wrote:

> On 11/29/2012 12:15 PM, Jim Meyering wrote:
>> Hugh Dickins wrote:
>>> On Thu, 29 Nov 2012, Jaegeuk Hanse wrote:
>> ...
>>>> But this time in which scenario will use it?
>>>
>>> I was not very convinced by the grep argument from Jim and Paul:
>>> that seemed to be grep holding on to a no-arbitrary-limits dogma,
>>> at the expense of its users, causing an absurd line-length issue,
>>> which use of SEEK_DATA happens to avoid in some cases.
>>>
>>> The cp of sparse files from Jeff and Dave was more convincing;
>>> but I still didn't see why little old tmpfs needed to be ahead
>>> of the pack.
>>>
>>> But at LinuxCon/Plumbers in San Diego in August, a more convincing
>>> case was made: I was hoping you would not ask, because I did not take
>>> notes, and cannot pass on the details - was it rpm building on tmpfs?
>>> I was convinced enough to promise support on tmpfs when support on
>>> ext4 goes in.
>>
>> Re the cp-vs-sparse-file case, the current FIEMAP-based code in GNU
>> cp is ugly and complicated enough that until recently it harbored a
>> hard-to-reproduce data-corrupting bug[*].  Now that SEEK_DATA/SEEK_HOLE
>> support work will work also for tmpfs and ext4, we can plan to remove
>> the FIEMAP-based code in favor of a simpler SEEK_DATA/SEEK_HOLE-based
>> implementation.
> How do we teach du(1) to aware of the real disk footprint with Btrfs
> clone or OCFS2 reflinked files if we remove the FIEMAP-based code?
>
> How about if we still keep it there, and introduce SEEK_DATA/SEEK_HOLE
> code to the extent-scan module which is dedicated to deal with sparse files?

Hi Jeff,
By "removing the FIEMAP-based code" I mean the uses in copy.c.
All of that should remain independent of how du does its job,
so if FIEMAP is required for your planned du enhancement,
then feel free to use it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
