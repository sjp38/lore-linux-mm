Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 700728E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 20:57:07 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d71so521207pgc.1
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 17:57:07 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id ba9si17014169plb.109.2019.01.22.17.57.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 17:57:06 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] Page flags, can we free up space ?
References: <20190122201744.GA3939@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6e4a377d-8f06-7b2c-4be7-23da72ccb18e@oracle.com>
Date: Tue, 22 Jan 2019 17:56:47 -0800
MIME-Version: 1.0
In-Reply-To: <20190122201744.GA3939@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>

On 1/22/19 12:17 PM, Jerome Glisse wrote:
> So lattely i have been looking at page flags and we are using 6 flags
> for memory reclaim and compaction:
> 
>     PG_referenced
>     PG_lru
>     PG_active
>     PG_workingset
>     PG_reclaim
>     PG_unevictable
> 
> On top of which you can add the page anonymous flag (anonymous or
> share memory)
>     PG_anon // does not exist, lower bit of page->mapping
> 
> And also the movable flag (which alias with KSM)
>     PG_movable // does not exist, lower bit of page->mapping
> 
> 
> So i would like to explore if there is a way to express the same amount
> of information with less bits. My methodology is to exhaustively list
> all the possible states (valid combination of above flags) and then to
> see how we change from one state to another (what event trigger the change
> like mlock(), page being referenced, ...) and under which rules (ie do we
> hold the page lock, zone lock, ...).
> 
> My hope is that there might be someway to use less bits to express the
> same thing. I am doing this because for my work on generic page write
> protection (ie KSM for file back page) which i talk about last year and
> want to talk about again ;) I will need to unalias the movable bit from
> KSM bit.
> 
> 
> Right now this is more a temptative ie i do not know if i will succeed,
> in any case i can report on failure or success and discuss my finding to
> get people opinions on the matter.
> 
> 
> I think everyone interested in mm will be interested in this topic :)

Explicitly adding Matthew on Cc as I am pretty sure he has been working
in this area.

-- 
Mike Kravetz
