Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 216616B000A
	for <linux-mm@kvack.org>; Sun,  7 Oct 2018 18:09:17 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c4-v6so16154370plz.20
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 15:09:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d37-v6sor11435469pla.28.2018.10.07.15.09.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Oct 2018 15:09:15 -0700 (PDT)
Date: Sun, 7 Oct 2018 15:09:11 -0700
From: Dennis Zhou <dennis@kernel.org>
Subject: Re: [PATCH] percpu: stop leaking bitmap metadata blocks
Message-ID: <20181007220911.GA3425@dennisz-mbp.dhcp.thefacebook.com>
References: <1538901111-22823-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538901111-22823-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Hi Mike,

On Sun, Oct 07, 2018 at 11:31:51AM +0300, Mike Rapoport wrote:
> The commit ca460b3c9627 ("percpu: introduce bitmap metadata blocks")
> introduced bitmap metadata blocks. These metadata blocks are allocated
> whenever a new chunk is created, but they are never freed. Fix it.
> 
> Fixes: ca460b3c9627 ("percpu: introduce bitmap metadata blocks")
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: stable@vger.kernel.org
> ---
>  mm/percpu.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index d21cb13..25104cd 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1212,6 +1212,7 @@ static void pcpu_free_chunk(struct pcpu_chunk *chunk)
>  {
>  	if (!chunk)
>  		return;
> +	pcpu_mem_free(chunk->md_blocks);
>  	pcpu_mem_free(chunk->bound_map);
>  	pcpu_mem_free(chunk->alloc_map);
>  	pcpu_mem_free(chunk);

Ah a bit of a boneheaded miss on my part.. Thanks for catching this!
I've applied it to for-4.19-fixes.

Thanks,
Dennis
