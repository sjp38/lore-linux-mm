Message-ID: <457D7EBA.7070005@yahoo.com.au>
Date: Tue, 12 Dec 2006 02:52:26 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Status of buffered write path (deadlock fixes)
References: <45751712.80301@yahoo.com.au> <20061207195518.GG4497@ca-server1.us.oracle.com> <4578DBCA.30604@yahoo.com.au> <20061208234852.GI4497@ca-server1.us.oracle.com> <457D20AE.6040107@yahoo.com.au>
In-Reply-To: <457D20AE.6040107@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fasheh <mark.fasheh@oracle.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@google.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Mark Fasheh wrote:

>> ->commit_write() would probably do fine. Currently, block_prepare_write()
>> uses it to know which buffers were newly allocated (the file system 
>> specific
>> get_block_t sets the bit after allocation). I think we could safely move
>> the clearing of that bit to block_commit_write(), thus still allowing 
>> us to
>> detect and zero those blocks in generic_file_buffered_write()
> 
> 
> OK, great, I'll make a few patches and see how they look. What did you
> think of those other uninitialised buffer problems in my first email?

Hmm, doesn't look like we can do this either because at least GFS2
uses BH_New for its own special things.

Also, I don't know if the trick of only walking over BH_New buffers
will work anyway, since we may still need to release resources on
other buffers as well. As you say, filesystems are simply not set up
to expect this, which is a problem.

Maybe it isn't realistic to change the API this way, no matter how
bad it is presently.

What if we tackle the problem a different way?

1. In the case of no page in the pagecache (or an otherwise
!uptodate page), if the operation is a full-page write then we
first copy all the user data *then* lock the page *then* insert it
into pagecache and go on to call into the filesystem.

2. In the case of a !uptodate page and a partial-page write, then
we can first bring the page uptodate, then continue (goto 3).

3. In the case of an uptodate page, we could perform a full-length
commit_write so long as we didn't expand i_size further than was
copied, and were sure to trim off blocks allocated past that
point.

This scheme IMO is not as "nice" as the partial commit patches,
but in practical terms it may be much more realistic.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
