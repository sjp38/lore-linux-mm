Message-ID: <4522B846.5050501@oracle.com>
Date: Tue, 03 Oct 2006 15:21:42 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com>	<4518835D.3080702@oracle.com>	 <451886FB.50306@yahoo.com.au>	 <451BF7BC.1040807@oracle.com>	 <20060928093640.14ecb1b1.akpm@osdl.org>	 <20060928094023.e888d533.akpm@osdl.org>	<451BFB84.5070903@oracle.com>	 <20060928100306.0b58f3c7.akpm@osdl.org>	<451C01C8.7020104@oracle.com>	 <451C6AAC.1080203@yahoo.com.au>	<451D8371.2070101@oracle.com>	 <1159562724.13651.39.camel@lappy>	<451D89E7.7020307@oracle.com>	 <1159564637.13651.44.camel@lappy>	<20060929144421.48f9f1bd.akpm@osdl.org>	 <451D94A7.9060905@oracle.com>	<20060929152951.0b763f6a.akpm@osdl.org>	 <451F425F.8030609@oracle.com>	<4520FFB6.3040801@RedHat.com>	 <1159795522.6143.7.camel@lade.trondhjem.org>	 <20061002095727.05cd052f.akpm@osdl.org>	<4521460B.8000504@RedHat.com>	 <20061002112005.d02f84f7.akpm@osdl.o! rg> <45216233.5010602@RedHat.com>	 <4521C79A.6090102@oracle.com> <1159849117.5420.17.camel@lade.trondhjem.org>	 <4522B112.3030207@oracle.com> <1159902601.23752.11.camel@lade.trondhj!
 em.org>
In-Reply-To: <1159902601.23752.11.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <SteveD@redhat.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Trond Myklebust wrote:
> On Tue, 2006-10-03 at 14:50 -0400, Chuck Lever wrote:
> 
>>>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>>>> index 377839b..fe69c39 100644
>>>> --- a/fs/nfs/direct.c
>>>> +++ b/fs/nfs/direct.c
>>>> @@ -823,7 +823,7 @@ ssize_t nfs_file_direct_write(struct kio
>>>>  	 *      occur before the writes complete.  Kind of racey.
>>>>  	 */
>>>>  	if (mapping->nrpages)
>>>> -		invalidate_inode_pages2(mapping);
>>>> +		nfs_invalidate_mapping(mapping->host, mapping);
>>> This looks wrong. Why are we bumping the NFSIOS_DATAINVALIDATE counter
>>> on a direct write? We're not registering a cache consistency problem
>>> here.
>> We're looking for potential races between direct I/O and cache 
>> invalidation, among others.  Is your concern that this may report false 
>> positives?
> 
> No. I simply don't see what the use case is for this statistic. AFAICS
> it is purely a debugging tool for _developers_. That would have
> absolutely no place at all in /proc/self/mountstats, which is supposed
> to provide useful statistics for _administrators_.

Don't you think admins need to know when the client has potentially 
caused data corruption?

>> I'm not sure this invalidation is useful in any event.  Direct writes 
>> are treated like some other client has modified the file, so cached 
>> pages will get invalidated eventually anyway.  Maybe we should just 
>> remove this one?
> 
> That would break the principle that if one process modifies the file,
> then all processes on the same client will immediately see those
> changes.

We could achieve that simply by setting the NFS_INO_INVALID_DATA flag in 
nfs_file_direct_write() and/or nfs_direct_write_complete().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
