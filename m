Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C56B66B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 05:05:05 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x63so10162091pfx.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 02:05:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e77si7024589pfj.217.2017.03.02.02.05.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 02:05:04 -0800 (PST)
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
 <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp>
Date: Thu, 2 Mar 2017 19:04:48 +0900
MIME-Version: 1.0
In-Reply-To: <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, mhocko@suse.com
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On 2017/03/02 14:19, Xiong Zhou wrote:
> On Wed, Mar 01, 2017 at 04:37:31PM -0800, Christoph Hellwig wrote:
>> On Wed, Mar 01, 2017 at 12:46:34PM +0800, Xiong Zhou wrote:
>>> Hi,
>>>
>>> It's reproduciable, not everytime though. Ext4 works fine.
>>
>> On ext4 fsstress won't run bulkstat because it doesn't exist.  Either
>> way this smells like a MM issue to me as there were not XFS changes
>> in that area recently.
> 
> Yap.
> 
> First bad commit:
> 
> commit 5d17a73a2ebeb8d1c6924b91e53ab2650fe86ffb
> Author: Michal Hocko <mhocko@suse.com>
> Date:   Fri Feb 24 14:58:53 2017 -0800
> 
>     vmalloc: back off when the current task is killed
> 
> Reverting this commit on top of
>   e5d56ef Merge tag 'watchdog-for-linus-v4.11'
> survives the tests.
> 

Looks like kmem_zalloc_greedy() is broken.
It loops forever until vzalloc() succeeds.
If somebody (not limited to the OOM killer) sends SIGKILL and
vmalloc() backs off, kmem_zalloc_greedy() will loop forever.

----------------------------------------
void *
kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
{
        void            *ptr;
        size_t          kmsize = maxsize;

        while (!(ptr = vzalloc(kmsize))) {
                if ((kmsize >>= 1) <= minsize)
                        kmsize = minsize;
        }
        if (ptr)
                *size = kmsize;
        return ptr;
}
----------------------------------------

So, commit 5d17a73a2ebeb8d1("vmalloc: back off when the current task is
killed") implemented __GFP_KILLABLE flag and automatically applied that
flag. As a result, those who are not ready to fail upon SIGKILL are
confused. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
