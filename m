Message-ID: <451A38B7.9040103@yahoo.com.au>
Date: Wed, 27 Sep 2006 18:39:19 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com>	<20060925141036.73f1e2b3.akpm@osdl.org>	<45185D7E.6070104@yahoo.com.au>	<451862C5.1010900@oracle.com>	<45186481.1090306@yahoo.com.au>	<45186DC3.7000902@oracle.com>	<451870C6.6050008@yahoo.com.au>	<4518835D.3080702@oracle.com>	<4518C7F1.3050809@yahoo.com.au>	<4519273C.3000301@oracle.com>	<451A025E.7020008@yahoo.com.au> <20060927012543.3c8657c6.akpm@osdl.org>
In-Reply-To: <20060927012543.3c8657c6.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: chuck.lever@oracle.com, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>On Wed, 27 Sep 2006 14:47:26 +1000
>Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
>
>>truncate_inode_pages will a) throw away everything including dirty 
>>pages, and b) probably be fairly
>>racy unless the inode's i_size (for normal files) is modified.
>>
>>We really want to make an invalidation that works properly for you.
>>
>>If you can guarantee that a pagecache page can never get mapped to a 
>>user mapping (eg. perhaps for
>>directories and symlinks) and also ensure that you don't dirty it via 
>>the filesystem, then you don't
>>have to worry about it becoming dirty, so we can skip the checks Andrew 
>>has added and maybe add a
>>WARN_ON(PageDirty()).
>>
>
>None of that is true for when invalidate_inode_pages2() is used by
>block-backed direct-io.
>

Sure, you wouldn't be able to skip those checks for direct IO, just for the
NFS usage.

>We should fix it for that application..
>

I thought direct IO fell back to buffered IO when the teardown failed. I
was surprised that it didn't and gave me errors when I was testing. Do
you see a better way to handle the direct IO case?

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
