Message-ID: <457F4EEE.9000601@yahoo.com.au>
Date: Wed, 13 Dec 2006 11:53:02 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Status of buffered write path (deadlock fixes)
References: <45751712.80301@yahoo.com.au> <20061207195518.GG4497@ca-server1.us.oracle.com> <4578DBCA.30604@yahoo.com.au> <20061208234852.GI4497@ca-server1.us.oracle.com> <457D20AE.6040107@yahoo.com.au> <457D7EBA.7070005@yahoo.com.au> <20061212223109.GG6831@ca-server1.us.oracle.com>
In-Reply-To: <20061212223109.GG6831@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fasheh <mark.fasheh@oracle.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@google.com>
List-ID: <linux-mm.kvack.org>

Mark Fasheh wrote:
> On Tue, Dec 12, 2006 at 02:52:26AM +1100, Nick Piggin wrote:
> 
>>Nick Piggin wrote:
>>
>>Hmm, doesn't look like we can do this either because at least GFS2
>>uses BH_New for its own special things.
>>
>>Also, I don't know if the trick of only walking over BH_New buffers
>>will work anyway, since we may still need to release resources on
>>other buffers as well.
> 
> 
> Oh, my idea was that only the range passed to ->commit() would be walked,
> but any BH_New buffers (regardless of where they are in the page) would be
> passed to the journal as well. So the logic would be:
> 
> for all the buffers in the page:
>   If the buffer is new, or it is within the range passed to commit, pass to
>   the journal.
> 
> Is there anything I'm still missing here?

If the buffer is not new, outside the commit range (and inside the prepare),
then it does not get passed to the journal. I'm not familiar with jbd, but
this seems that it could cause a problem eg. in data journalling mode?

>>As you say, filesystems are simply not set up to expect this, which is a
>>problem.
>>
>>Maybe it isn't realistic to change the API this way, no matter how
>>bad it is presently.
> 
> 
> We definitely agree. It's not intuitive that the range should change
> between ->prepare_write() and ->commit_write() and IMHO, all the issues
> we've found are good evidence that this particular approach will be
> problematic.

Yes.

>>What if we tackle the problem a different way?
>>
>>1. In the case of no page in the pagecache (or an otherwise
>>!uptodate page), if the operation is a full-page write then we
>>first copy all the user data *then* lock the page *then* insert it
>>into pagecache and go on to call into the filesystem.
> 
> 
> Silly question - what's preventing a reader from filling the !uptodate page with disk
> data while the writer is copying the user buffer into it?

Not silly -- I guess that is the main sticking point. Luckily *most*
!uptodate pages will be ones that we have newly allocated so will
not be in pagecache yet.

If it is in pagecache, we could do one of a number of things: either
remove it or try to bring it uptodate ourselves. I'm not yet sure if
either of these actions will cause other problems, though :P

If both of those are really going to cause problems, then we could
solve this in a more brute force way (assuming that !uptodate, locked
pages, in pagecache at this point are very rare -- AFAIKS these will
only be caused by IO errors?). We could allocate another, temporary
page and copy the contents into there first, then into the target
page after the prepare_write.

>>2. In the case of a !uptodate page and a partial-page write, then
>>we can first bring the page uptodate, then continue (goto 3).
>>
>>3. In the case of an uptodate page, we could perform a full-length
>>commit_write so long as we didn't expand i_size further than was
>>copied, and were sure to trim off blocks allocated past that
>>point.
>>
>>This scheme IMO is not as "nice" as the partial commit patches,
>>but in practical terms it may be much more realistic.
> 
> 
> It seems more realistic in that it makes sure the write is properly setup
> before calling into the file system. What do you think is not as nice about
> it?

The corner cases. However I guess the current scheme was building up
corner cases as well, so you might be right.

-- 
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
