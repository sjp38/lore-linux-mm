Date: Mon, 06 May 2002 07:40:46 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: [RFC][PATCH] dcache and rmap
Message-ID: <17314927.1020670845@[10.10.2.3]>
In-Reply-To: <200205060354.52173.tomlins@cam.org>
References: <200205060354.52173.tomlins@cam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > I got tired of finding my box with 50-60% percent of memory tied
>> > up in dentry/inode caches every morning after update-db runs or
>> > after doing a find / -name "*" to generate a list of files for
>> > backups.  So I decided to make a stab at fixing this.
>> 
>> Are you actually out of memory at this point, and they're consuming
>> space you really need?
> 
> Think of this another way.  There are 100000+ dentry/inodes in memory
> comsuming 250M or so.  Meanwhile load is light and the background
> aging is able to supply pages for the freelist.  We do not reclaim this
> storage until we have vm pressure.  Usually this pressure is artifical, 
> if we had reclaimed the storage it would not have occured, our caches
> would have more useful data in them, and half the memory would not
> sit idle for half a day.  
> 
> We age the rest of the memory to keep it hot.   Rmap does a good job 
> and keeps the freelist heathly.  In this case nothing ages the dentries
> and they get very cold.  My code ensures that the memory consumed 
> by the, potentially cold, dentries/inodes is not excessive.

If there's no pressure on memory, then using it for caches is a good
thing. Why throw away data before we're out of space? If we are under
pressure on memory then dcache should shrink easily and rapidly. If
it's not, then make it shrink properly, don't just limit it to an
arbitrary size that may be totally unsuitable for some workloads.
You could even age it instead ... that'd make more sense than
restricting it to a static size.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
