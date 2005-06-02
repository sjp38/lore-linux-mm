Date: Wed, 1 Jun 2005 18:56:37 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] vmalloc with the ability to specify a node
In-Reply-To: <20050602013421.GS25321@esmail.cup.hp.com>
Message-ID: <Pine.LNX.4.62.0506011852010.11935@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0506011551240.10915@schroedinger.engr.sgi.com>
 <20050602013421.GS25321@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Grant Grundler <iod00d@hp.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jun 2005, Grant Grundler wrote:

> grundler@gsyprf3:/usr/src/linux-2.6$ fgrep vmalloc drivers/net/*/*c
> drivers/net/e1000/e1000.mod.c:  { 0xd6ee688f, "vmalloc" },
> drivers/net/e1000/e1000_main.c: txdr->buffer_info = vmalloc(size);
> drivers/net/e1000/e1000_main.c: rxdr->buffer_info = vmalloc(size);
> drivers/net/ixgb/ixgb.mod.c:    { 0xd6ee688f, "vmalloc" },
> drivers/net/ixgb/ixgb_main.c:   txdr->buffer_info = vmalloc(size);
> drivers/net/ixgb/ixgb_main.c:   rxdr->buffer_info = vmalloc(size);
> grundler@gsyprf3:/usr/src/linux-2.6$ fgrep vmalloc drivers/scsi/*/*c
> drivers/scsi/qla2xxx/qla2xxx.mod.c:     { 0xd6ee688f, "vmalloc" },
> drivers/scsi/qla2xxx/qla_os.c:#include <linux/vmalloc.h>
> drivers/scsi/qla2xxx/qla_os.c:                  ha->fw_dump_buffer = (char *)vmalloc(dump_size);

Thanks. We use the qla2xxx so it would also help us.
 
> Could someone explain to me why this is a bad thing on NUMA machines?

Because the vmalloc now allocated memory from the node of the cpu that 
is executing the initialization code and not memory on the node where the 
device is located. Its best to service the device on the node of the device 
accessing device local memory. vmalloc_node would allow to specify where 
to place device control structures.

> I assume it has something to do with mem locality and how the memory
> is used.

Correct.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
